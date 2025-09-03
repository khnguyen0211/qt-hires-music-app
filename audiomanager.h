#ifndef AUDIOMANAGER_H
#define AUDIOMANAGER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QDebug>
#include <vector>
#include <cstring>
#include <cstdint>

extern "C" {
#include "portaudio.h"
}

class AudioManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(double duration READ duration NOTIFY durationChanged)

public:
    explicit AudioManager(QObject *parent = nullptr);
    ~AudioManager();

    // Properties
    bool isPlaying() const { return isPlaying_; }
    double progress() const { return progress_; }
    QString currentFile() const { return currentFile_; }
    double duration() const { return duration_; }

    // Q_INVOKABLE methods (có thể gọi từ QML)
    Q_INVOKABLE bool loadFile(const QString& filePath);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE QStringList getAudioDevices();

signals:
    void isPlayingChanged();
    void progressChanged();
    void currentFileChanged();
    void durationChanged();
    void errorOccurred(const QString& error);

private slots:
    void updateProgress();

private:
    struct AudioData {
        std::vector<int16_t> samples;
        size_t totalFrames;
        size_t currentFrame;
        int channels;
        unsigned int sampleRate;

        AudioData() : totalFrames(0), currentFrame(0), channels(0), sampleRate(0) {}

        void reset() {
            samples.clear();
            totalFrames = 0;
            currentFrame = 0;
            channels = 0;
            sampleRate = 0;
        }
    };

    static int audioCallback(const void *inputBuffer, void *outputBuffer,
                             unsigned long framesPerBuffer,
                             const PaStreamCallbackTimeInfo* timeInfo,
                             PaStreamCallbackFlags statusFlags,
                             void *userData);

    int processAudio(const void *inputBuffer, void *outputBuffer,
                     unsigned long framesPerBuffer,
                     const PaStreamCallbackTimeInfo* timeInfo,
                     PaStreamCallbackFlags statusFlags);

    bool loadWAV(const QString& filePath);
    bool initializePortAudio();
    void cleanupPortAudio();

    AudioData audioData_;
    PaStream* stream_;
    bool isInitialized_;
    bool isPlaying_;
    double progress_;
    QString currentFile_;
    double duration_;
    QTimer* progressTimer_;
};

#endif
