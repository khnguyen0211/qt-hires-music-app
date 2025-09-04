#ifndef AUDIOMANAGER_H
#define AUDIOMANAGER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QStringList>
#include <memory>
#include "audio_decoder.h"
#include "audio_player.h"
#include "playlist_manager.h"

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
    Q_PROPERTY(PlaylistManager* playlist READ playlist CONSTANT)

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
    PlaylistManager* playlist() const { return playlistManager_.get(); }

    Q_INVOKABLE bool loadFile(const QString& filePath);
    Q_INVOKABLE void addToPlaylist(const QString& filePath);
    Q_INVOKABLE void addMultipleToPlaylist(const QStringList& filePaths);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void playNext();
    Q_INVOKABLE void playPrevious();
    Q_INVOKABLE void playTrackAt(int index);
    Q_INVOKABLE void seek(double position);
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
    bool loadCurrentTrack();
    void onTrackFinished();

    std::unique_ptr<AudioPlayer> player_;
    std::unique_ptr<PlaylistManager> playlistManager_;
    double progress_;
    QString currentFile_;
    double duration_;
    QTimer* progressTimer_;
    bool isLoading_;
    QString loadingStatus_;
    bool autoAdvance_;
};

#endif // AUDIOMANAGER_H
