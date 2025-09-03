#ifndef AUDIOMANAGER_H
#define AUDIOMANAGER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QStringList>
#include <memory>
#include "audio_decoder.h"
#include "audio_player.h"

class AudioManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(double duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(bool isFfmpegAvailable READ isFfmpegAvailable NOTIFY isFfmpegAvailableChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString loadingStatus READ loadingStatus NOTIFY loadingStatusChanged)

public:
    explicit AudioManager(QObject* parent = nullptr);
    ~AudioManager();

    bool isPlaying() const;
    double progress() const { return progress_; }
    QString currentFile() const { return currentFile_; }
    double duration() const { return duration_; }
    bool isFfmpegAvailable() const;
    bool isLoading() const { return isLoading_; }
    QString loadingStatus() const { return loadingStatus_; }

    Q_INVOKABLE bool loadFile(const QString& filePath);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE QStringList getAudioDevices();
    Q_INVOKABLE QStringList getSupportedFormats();

signals:
    void isPlayingChanged();
    void progressChanged();
    void currentFileChanged();
    void durationChanged();
    void isFfmpegAvailableChanged();
    void isLoadingChanged();
    void loadingStatusChanged();
    void errorOccurred(const QString& error);

private slots:
    void updateProgress();

private:
    void setLoadingStatus(const QString& status);
    void setLoading(bool loading);

    std::unique_ptr<AudioPlayer> player_;
    double progress_;
    QString currentFile_;
    double duration_;
    QTimer* progressTimer_;
    bool isLoading_;
    QString loadingStatus_;
};

#endif // AUDIOMANAGER_H
