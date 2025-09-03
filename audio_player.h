#ifndef AUDIO_PLAYER_H
#define AUDIO_PLAYER_H

#include "audio_decoder.h"
#include <QStringList>
#include <memory>

extern "C" {
#include "portaudio.h"
}

enum class PlaybackState {
    Stopped,
    Playing,
    Paused
};

class AudioPlayer {
public:
    AudioPlayer();
    ~AudioPlayer();

    bool initialize();
    void shutdown();

    bool loadAudio(const AudioData& audioData);
    bool play();
    bool pause();
    bool stop();

    PlaybackState getState() const { return state_; }
    double getProgress() const;
    double getDuration() const { return audioData_.getDuration(); }
    QStringList getAvailableDevices() const;

    bool isInitialized() const { return initialized_; }

private:
    static int audioCallback(const void* inputBuffer, void* outputBuffer,
                            unsigned long framesPerBuffer,
                            const PaStreamCallbackTimeInfo* timeInfo,
                            PaStreamCallbackFlags statusFlags,
                            void* userData);

    int processAudio(const void* inputBuffer, void* outputBuffer,
                    unsigned long framesPerBuffer,
                    const PaStreamCallbackTimeInfo* timeInfo,
                    PaStreamCallbackFlags statusFlags);

    bool createStream();
    void closeStream();

    AudioData audioData_;
    size_t currentFrame_;
    PaStream* stream_;
    PlaybackState state_;
    bool initialized_;
};

#endif // AUDIO_PLAYER_H
