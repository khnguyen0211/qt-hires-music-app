#include "audiomanager.h"
#include <QUrl>
#include <QFileInfo>
#include <fstream>
#include <iostream>
#include <cstring>

AudioManager::AudioManager(QObject *parent)
    : QObject(parent)
    , stream_(nullptr)
    , isInitialized_(false)
    , isPlaying_(false)
    , progress_(0.0)
    , duration_(0.0)
{
    progressTimer_ = new QTimer(this);
    connect(progressTimer_, &QTimer::timeout, this, &AudioManager::updateProgress);

    initializePortAudio();
}

AudioManager::~AudioManager()
{
    cleanupPortAudio();
}

bool AudioManager::initializePortAudio()
{
    PaError err = Pa_Initialize();
    if (err != paNoError) {
        qDebug() << "PortAudio initialization failed:" << Pa_GetErrorText(err);
        emit errorOccurred(QString("Failed to initialize audio system: %1").arg(Pa_GetErrorText(err)));
        return false;
    }

    isInitialized_ = true;
    qDebug() << "PortAudio initialized successfully";
    return true;
}

void AudioManager::cleanupPortAudio()
{
    if (stream_) {
        Pa_StopStream(stream_);
        Pa_CloseStream(stream_);
        stream_ = nullptr;
    }

    if (isInitialized_) {
        Pa_Terminate();
        isInitialized_ = false;
    }
}

bool AudioManager::loadFile(const QString& filePath)
{
    qDebug() << "Loading file:" << filePath;

    // Stop current playback
    stop();

    // Handle QML file URLs
    QString actualPath = filePath;
    if (filePath.startsWith("file://")) {
        actualPath = QUrl(filePath).toLocalFile();
    }

    if (!loadWAV(actualPath)) {
        emit errorOccurred("Failed to load audio file: " + actualPath);
        return false;
    }

    currentFile_ = QFileInfo(actualPath).baseName();
    duration_ = static_cast<double>(audioData_.totalFrames) / audioData_.sampleRate;

    emit currentFileChanged();
    emit durationChanged();

    qDebug() << "File loaded successfully. Duration:" << duration_ << "seconds";
    return true;
}

bool AudioManager::loadWAV(const QString& filePath)
{
    std::ifstream file(filePath.toStdString(), std::ios::binary);
    if (!file.is_open()) {
        qDebug() << "Cannot open file:" << filePath;
        return false;
    }

    // Reset audio data
    audioData_.reset();

    // Read WAV header
    char header[44];
    file.read(header, 44);

    // Check WAV format
    if (strncmp(header, "RIFF", 4) != 0 || strncmp(header + 8, "WAVE", 4) != 0) {
        qDebug() << "Invalid WAV format";
        return false;
    }

    // Extract header info
    audioData_.channels = *reinterpret_cast<int16_t*>(header + 22);
    audioData_.sampleRate = static_cast<unsigned int>(*reinterpret_cast<int32_t*>(header + 24));
    int bitsPerSample = *reinterpret_cast<int16_t*>(header + 34);
    int dataSize = *reinterpret_cast<int32_t*>(header + 40);

    qDebug() << "WAV Info - Channels:" << audioData_.channels
             << "Sample Rate:" << audioData_.sampleRate
             << "Bits per Sample:" << bitsPerSample
             << "Data Size:" << dataSize;

    // Only support 16-bit PCM
    if (bitsPerSample != 16) {
        qDebug() << "Only 16-bit WAV files are supported";
        return false;
    }

    // Calculate frames and read data
    audioData_.totalFrames = dataSize / (audioData_.channels * 2);
    audioData_.currentFrame = 0;
    audioData_.samples.resize(dataSize / 2);

    file.read(reinterpret_cast<char*>(audioData_.samples.data()), dataSize);
    file.close();

    return true;
}

void AudioManager::play()
{
    if (audioData_.samples.empty()) {
        qDebug() << "No audio data loaded";
        return;
    }

    if (isPlaying_) {
        qDebug() << "Already playing";
        return;
    }

    if (!stream_) {
        // Setup stream parameters
        PaStreamParameters outputParameters;
        outputParameters.device = Pa_GetDefaultOutputDevice();
        if (outputParameters.device == paNoDevice) {
            emit errorOccurred("No audio output device found");
            return;
        }

        outputParameters.channelCount = audioData_.channels;
        outputParameters.sampleFormat = paInt16;
        outputParameters.suggestedLatency = Pa_GetDeviceInfo(outputParameters.device)->defaultLowOutputLatency;
        outputParameters.hostApiSpecificStreamInfo = nullptr;

        // Open stream
        PaError err = Pa_OpenStream(&stream_,
                                    nullptr, // no input
                                    &outputParameters,
                                    audioData_.sampleRate,
                                    256, // frames per buffer
                                    paClipOff,
                                    audioCallback,
                                    this);

        if (err != paNoError) {
            emit errorOccurred(QString("Failed to open audio stream: %1").arg(Pa_GetErrorText(err)));
            return;
        }
    }

    // Start stream
    PaError err = Pa_StartStream(stream_);
    if (err != paNoError) {
        emit errorOccurred(QString("Failed to start audio stream: %1").arg(Pa_GetErrorText(err)));
        return;
    }

    isPlaying_ = true;
    progressTimer_->start(100); // Update progress every 100ms
    emit isPlayingChanged();

    qDebug() << "Playback started";
}

void AudioManager::pause()
{
    if (!isPlaying_) return;

    if (stream_) {
        Pa_StopStream(stream_);
    }

    isPlaying_ = false;
    progressTimer_->stop();
    emit isPlayingChanged();

    qDebug() << "Playback paused";
}

void AudioManager::stop()
{
    if (stream_) {
        Pa_StopStream(stream_);
        Pa_CloseStream(stream_);
        stream_ = nullptr;
    }

    audioData_.currentFrame = 0;
    isPlaying_ = false;
    progress_ = 0.0;
    progressTimer_->stop();

    emit isPlayingChanged();
    emit progressChanged();

    qDebug() << "Playback stopped";
}

QStringList AudioManager::getAudioDevices()
{
    QStringList devices;

    if (!isInitialized_) return devices;

    int deviceCount = Pa_GetDeviceCount();
    for (int i = 0; i < deviceCount; i++) {
        const PaDeviceInfo* deviceInfo = Pa_GetDeviceInfo(i);
        if (deviceInfo->maxOutputChannels > 0) {
            devices << QString("%1: %2").arg(i).arg(deviceInfo->name);
        }
    }

    return devices;
}

void AudioManager::updateProgress()
{
    if (audioData_.totalFrames > 0) {
        progress_ = static_cast<double>(audioData_.currentFrame) / audioData_.totalFrames;
        emit progressChanged();

        // Check if playback finished
        if (audioData_.currentFrame >= audioData_.totalFrames) {
            stop();
        }
    }
}

int AudioManager::audioCallback(const void *inputBuffer, void *outputBuffer,
                                unsigned long framesPerBuffer,
                                const PaStreamCallbackTimeInfo* timeInfo,
                                PaStreamCallbackFlags statusFlags,
                                void *userData)
{
    return static_cast<AudioManager*>(userData)->processAudio(
        inputBuffer, outputBuffer, framesPerBuffer, timeInfo, statusFlags);
}

int AudioManager::processAudio(const void *inputBuffer, void *outputBuffer,
                               unsigned long framesPerBuffer,
                               const PaStreamCallbackTimeInfo* timeInfo,
                               PaStreamCallbackFlags statusFlags)
{
    int16_t* output = static_cast<int16_t*>(outputBuffer);

    // Calculate frames remaining
    size_t framesRemaining = audioData_.totalFrames - audioData_.currentFrame;
    size_t framesToCopy = std::min(static_cast<size_t>(framesPerBuffer), framesRemaining);

    if (framesToCopy > 0) {
        // Copy audio data
        memcpy(output,
               &audioData_.samples[audioData_.currentFrame * audioData_.channels],
               framesToCopy * audioData_.channels * sizeof(int16_t));

        audioData_.currentFrame += framesToCopy;

        // Fill remaining with silence
        if (framesToCopy < framesPerBuffer) {
            memset(&output[framesToCopy * audioData_.channels], 0,
                   (framesPerBuffer - framesToCopy) * audioData_.channels * sizeof(int16_t));
        }
    } else {
        // End of data, fill with silence
        memset(output, 0, framesPerBuffer * audioData_.channels * sizeof(int16_t));
        return paComplete;
    }

    return paContinue;
}
