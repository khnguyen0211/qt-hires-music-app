#include "audio_player.h"
#include <QDebug>
#include <cstring>
#include <algorithm>

AudioPlayer::AudioPlayer()
    : currentFrame_(0)
    , stream_(nullptr)
    , state_(PlaybackState::Stopped)
    , initialized_(false) {
}

AudioPlayer::~AudioPlayer() {
    shutdown();
}

bool AudioPlayer::initialize() {
    PaError err = Pa_Initialize();
    if (err != paNoError) {
        qDebug() << "PortAudio initialization failed:" << Pa_GetErrorText(err);
        return false;
    }

    initialized_ = true;
    qDebug() << "PortAudio initialized successfully";
    return true;
}

void AudioPlayer::shutdown() {
    closeStream();
    
    if (initialized_) {
        Pa_Terminate();
        initialized_ = false;
    }
}

bool AudioPlayer::loadAudio(const AudioData& audioData) {
    if (!audioData.isValid()) {
        qDebug() << "Invalid audio data";
        return false;
    }

    stop();
    audioData_ = audioData;
    currentFrame_ = 0;
    
    qDebug() << "Audio loaded - Duration:" << audioData_.getDuration() << "seconds";
    return true;
}

bool AudioPlayer::play() {
    if (!audioData_.isValid()) {
        qDebug() << "No valid audio data loaded";
        return false;
    }

    if (state_ == PlaybackState::Playing) {
        return true;
    }

    if (!stream_ && !createStream()) {
        return false;
    }

    PaError err = Pa_StartStream(stream_);
    if (err != paNoError) {
        qDebug() << "Failed to start audio stream:" << Pa_GetErrorText(err);
        return false;
    }

    state_ = PlaybackState::Playing;
    qDebug() << "Playback started";
    return true;
}

bool AudioPlayer::pause() {
    if (state_ != PlaybackState::Playing) {
        return true;
    }

    if (stream_) {
        PaError err = Pa_StopStream(stream_);
        if (err != paNoError) {
            qDebug() << "Failed to pause stream:" << Pa_GetErrorText(err);
            return false;
        }
    }

    state_ = PlaybackState::Paused;
    qDebug() << "Playback paused";
    return true;
}

bool AudioPlayer::stop() {
    closeStream();
    currentFrame_ = 0;
    state_ = PlaybackState::Stopped;
    
    qDebug() << "Playback stopped";
    return true;
}

double AudioPlayer::getProgress() const {
    if (audioData_.totalFrames == 0) {
        return 0.0;
    }
    return static_cast<double>(currentFrame_) / audioData_.totalFrames;
}

void AudioPlayer::seek(double position) {
    if (!audioData_.isValid()) {
        return;
    }
    
    // Clamp position between 0.0 and 1.0
    position = std::max(0.0, std::min(1.0, position));
    
    // Calculate the target frame
    size_t targetFrame = static_cast<size_t>(position * audioData_.totalFrames);
    
    // Update current frame position
    currentFrame_ = targetFrame;
    
    qDebug() << "Seeking to position:" << position << "frame:" << targetFrame;
}

QStringList AudioPlayer::getAvailableDevices() const {
    QStringList devices;

    if (!initialized_) {
        return devices;
    }

    int deviceCount = Pa_GetDeviceCount();
    for (int i = 0; i < deviceCount; i++) {
        const PaDeviceInfo* deviceInfo = Pa_GetDeviceInfo(i);
        if (deviceInfo->maxOutputChannels > 0) {
            devices << QString("%1: %2").arg(i).arg(deviceInfo->name);
        }
    }

    return devices;
}

bool AudioPlayer::createStream() {
    if (stream_) {
        return true;
    }

    PaStreamParameters outputParameters;
    outputParameters.device = Pa_GetDefaultOutputDevice();
    if (outputParameters.device == paNoDevice) {
        qDebug() << "No audio output device found";
        return false;
    }

    outputParameters.channelCount = audioData_.channels;
    outputParameters.sampleFormat = paInt16;
    outputParameters.suggestedLatency = Pa_GetDeviceInfo(outputParameters.device)->defaultLowOutputLatency;
    outputParameters.hostApiSpecificStreamInfo = nullptr;

    PaError err = Pa_OpenStream(&stream_,
                                nullptr,
                                &outputParameters,
                                audioData_.sampleRate,
                                256,
                                paClipOff,
                                audioCallback,
                                this);

    if (err != paNoError) {
        qDebug() << "Failed to open audio stream:" << Pa_GetErrorText(err);
        return false;
    }

    return true;
}

void AudioPlayer::closeStream() {
    if (stream_) {
        Pa_StopStream(stream_);
        Pa_CloseStream(stream_);
        stream_ = nullptr;
    }
}

int AudioPlayer::audioCallback(const void* inputBuffer, void* outputBuffer,
                              unsigned long framesPerBuffer,
                              const PaStreamCallbackTimeInfo* timeInfo,
                              PaStreamCallbackFlags statusFlags,
                              void* userData) {
    return static_cast<AudioPlayer*>(userData)->processAudio(
        inputBuffer, outputBuffer, framesPerBuffer, timeInfo, statusFlags);
}

int AudioPlayer::processAudio(const void* inputBuffer, void* outputBuffer,
                             unsigned long framesPerBuffer,
                             const PaStreamCallbackTimeInfo* timeInfo,
                             PaStreamCallbackFlags statusFlags) {
    int16_t* output = static_cast<int16_t*>(outputBuffer);

    size_t framesRemaining = audioData_.totalFrames - currentFrame_;
    size_t framesToCopy = std::min(static_cast<size_t>(framesPerBuffer), framesRemaining);

    if (framesToCopy > 0) {
        memcpy(output,
               &audioData_.samples[currentFrame_ * audioData_.channels],
               framesToCopy * audioData_.channels * sizeof(int16_t));

        currentFrame_ += framesToCopy;

        if (framesToCopy < framesPerBuffer) {
            memset(&output[framesToCopy * audioData_.channels], 0,
                   (framesPerBuffer - framesToCopy) * audioData_.channels * sizeof(int16_t));
        }
    } else {
        memset(output, 0, framesPerBuffer * audioData_.channels * sizeof(int16_t));
        return paComplete;
    }

    return paContinue;
}