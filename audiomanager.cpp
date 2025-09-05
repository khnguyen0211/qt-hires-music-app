#include "audiomanager.h"
#include <QUrl>
#include <QFileInfo>
#include <QDebug>

AudioManager::AudioManager(QObject* parent)
    : QObject(parent)
    , player_(std::make_unique<AudioPlayer>())
    , playlistManager_(std::make_unique<PlaylistManager>(this))
    , progress_(0.0)
    , duration_(0.0)
    , isLoading_(false)
    , loadingStatus_("Ready")
    , autoAdvance_(true)
{
    progressTimer_ = new QTimer(this);
    connect(progressTimer_, &QTimer::timeout, this, &AudioManager::updateProgress);

    if (!player_->initialize()) {
        qDebug() << "Failed to initialize audio player";
    }
}

AudioManager::~AudioManager() = default;

bool AudioManager::isPlaying() const {
    return player_ && player_->getState() == PlaybackState::Playing;
}

bool AudioManager::isFfmpegAvailable() const {
    return AudioDecoder::getSupportedFormats().size() > 1;
}

bool AudioManager::loadFile(const QString& filePath) {
    qDebug() << "Loading single file:" << filePath;
    playlistManager_->clearPlaylist();
    playlistManager_->addTrack(filePath);
    
    // Load track and auto-play if successful
    if (loadCurrentTrack()) {
        qDebug() << "Auto-playing loaded single track";
        play();
        return true;
    }
    qDebug() << "Failed to load track";
    return false;
}

void AudioManager::addToPlaylist(const QString& filePath) {
    bool wasEmpty = playlistManager_->trackCount() == 0;
    playlistManager_->addTrack(filePath);
    
    qDebug() << "Added track to playlist:" << filePath << "Was empty:" << wasEmpty;
    
    // Auto-play if this was the first track added
    if (wasEmpty && playlistManager_->trackCount() > 0) {
        qDebug() << "Auto-playing first track added to empty playlist";
        if (loadCurrentTrack()) {
            play();
        }
    }
}

void AudioManager::addMultipleToPlaylist(const QStringList& filePaths) {
    bool wasEmpty = playlistManager_->trackCount() == 0;
    playlistManager_->addTracks(filePaths);
    
    qDebug() << "Added" << filePaths.size() << "files to playlist. Was empty:" << wasEmpty << "Track count now:" << playlistManager_->trackCount();
    
    // Auto-play if this was the first batch added to empty playlist
    if (wasEmpty && playlistManager_->trackCount() > 0) {
        qDebug() << "Auto-playing first track from newly loaded playlist";
        qDebug() << "BEFORE loadCurrentTrack() - Current index:" << playlistManager_->currentIndex() << "hasNext:" << playlistManager_->hasNext() << "hasPrevious:" << playlistManager_->hasPrevious();
        
        if (loadCurrentTrack()) {
            qDebug() << "AFTER loadCurrentTrack() - Current index:" << playlistManager_->currentIndex() << "hasNext:" << playlistManager_->hasNext() << "hasPrevious:" << playlistManager_->hasPrevious();
            play();
        } else {
            qDebug() << "loadCurrentTrack() failed";
        }
    }
}

void AudioManager::playNext() {
    qDebug() << "playNext() called";
    qDebug() << "Before next() - currentIndex:" << playlistManager_->currentIndex() 
             << "trackCount:" << playlistManager_->trackCount()
             << "hasNext:" << playlistManager_->hasNext();
    
    if (playlistManager_->next()) {
        qDebug() << "next() succeeded - new currentIndex:" << playlistManager_->currentIndex();
        loadCurrentTrack();
        // Auto-play after switching to next track
        play();
    } else {
        qDebug() << "next() failed - hasNext was false";
    }
}

void AudioManager::playPrevious() {
    if (playlistManager_->previous()) {
        loadCurrentTrack();
        // Auto-play after switching to previous track
        play();
    }
}

void AudioManager::playTrackAt(int index) {
    if (playlistManager_->setCurrentIndex(index)) {
        loadCurrentTrack();
        // Auto-play when selecting a specific track
        play();
    }
}

bool AudioManager::loadCurrentTrack() {
    qDebug() << "loadCurrentTrack() called - currentIndex:" << playlistManager_->currentIndex();
    
    QString filePath = playlistManager_->currentFilePath();
    if (filePath.isEmpty()) {
        qDebug() << "loadCurrentTrack() failed - empty filePath";
        return false;
    }

    qDebug() << "Loading current track:" << filePath;

    stop();
    setLoading(true);
    setLoadingStatus("Loading audio file...");

    AudioData audioData;
    QString extension = QFileInfo(filePath).suffix().toLower();
    
    if (AudioDecoder::isFormatSupported(extension)) {
        setLoadingStatus("Loading " + extension.toUpper() + " file...");
        
        if (!AudioDecoder::loadAudioFile(filePath, audioData)) {
            setLoading(false);
            setLoadingStatus("Ready");
            emit errorOccurred("Failed to load audio file: " + filePath);
            return false;
        }
    } else {
        setLoading(false);
        setLoadingStatus("Ready");
        emit errorOccurred("Unsupported format: " + extension);
        return false;
    }

    if (!player_->loadAudio(audioData)) {
        setLoading(false);
        setLoadingStatus("Ready");
        emit errorOccurred("Failed to load audio data");
        return false;
    }

    currentFile_ = QFileInfo(filePath).baseName();
    duration_ = audioData.getDuration();
    progress_ = 0.0;

    // Update track duration in playlist
    Track* currentTrack = playlistManager_->currentTrack();
    if (currentTrack) {
        currentTrack->setDuration(duration_);
    }

    setLoading(false);
    setLoadingStatus("Ready");
    emit currentFileChanged();
    emit durationChanged();
    emit progressChanged();

    qDebug() << "Track loaded successfully. Duration:" << duration_ << "seconds";
    return true;
}


void AudioManager::play() {
    if (!player_) {
        emit errorOccurred("Audio player not initialized");
        return;
    }

    if (currentFile_.isEmpty() && playlistManager_->trackCount() > 0) {
        qDebug() << "No current track, loading first track from playlist";
        if (!loadCurrentTrack()) {
            emit errorOccurred("Failed to load track from playlist");
            return;
        }
    }

    if (currentFile_.isEmpty()) {
        emit errorOccurred("No audio file loaded. Please load a file first.");
        return;
    }

    if (player_->play()) {
        progressTimer_->start(100);
        emit isPlayingChanged();
        qDebug() << "Playback started";
    } else {
        emit errorOccurred("Failed to start playback");
    }
}

void AudioManager::pause() {
    if (player_ && player_->pause()) {
        progressTimer_->stop();
        emit isPlayingChanged();
        qDebug() << "Playback paused";
    }
}

void AudioManager::stop() {
    if (player_ && player_->stop()) {
        progress_ = 0.0;
        progressTimer_->stop();
        emit isPlayingChanged();
        emit progressChanged();
        qDebug() << "Playback stopped";
    }
}

void AudioManager::seek(double position) {
    if (!player_) {
        qDebug() << "Cannot seek: player not initialized";
        return;
    }
    
    // Clamp position between 0.0 and 1.0
    position = std::max(0.0, std::min(1.0, position));
    
    player_->seek(position);
    progress_ = position;
    
    emit progressChanged();
    qDebug() << "Seeking to position:" << position;
}

QStringList AudioManager::getAudioDevices() {
    return player_ ? player_->getAvailableDevices() : QStringList();
}

void AudioManager::updateProgress() {
    if (player_) {
        double newProgress = player_->getProgress();
        if (newProgress != progress_) {
            progress_ = newProgress;
            emit progressChanged();
        }

        if (player_->getState() == PlaybackState::Stopped && progress_ >= 1.0) {
            qDebug() << "Track finished";
            progressTimer_->stop();
            emit isPlayingChanged();
            onTrackFinished();
        }
    }
}

void AudioManager::onTrackFinished() {
    if (autoAdvance_ && playlistManager_->hasNext()) {
        qDebug() << "Auto-advancing to next track";
        playNext();
    }
}



QStringList AudioManager::getSupportedFormats() {
    return AudioDecoder::getSupportedFormats();
}


void AudioManager::setLoading(bool loading)
{
    if (isLoading_ != loading) {
        isLoading_ = loading;
        emit isLoadingChanged();
    }
}

void AudioManager::setLoadingStatus(const QString& status)
{
    if (loadingStatus_ != status) {
        loadingStatus_ = status;
        emit loadingStatusChanged();
    }
}
