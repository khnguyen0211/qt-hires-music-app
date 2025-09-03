#include "audiomanager.h"
#include <QUrl>
#include <QFileInfo>
#include <QDebug>

AudioManager::AudioManager(QObject* parent)
    : QObject(parent)
    , player_(std::make_unique<AudioPlayer>())
    , progress_(0.0)
    , duration_(0.0)
    , isLoading_(false)
    , loadingStatus_("Ready")
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
    qDebug() << "Loading file:" << filePath;

    stop();
    setLoading(true);
    setLoadingStatus("Loading audio file...");

    QString actualPath = filePath;
    if (filePath.startsWith("file://")) {
        actualPath = QUrl(filePath).toLocalFile();
    }

    AudioData audioData;
    QString extension = QFileInfo(actualPath).suffix().toLower();
    
    if (AudioDecoder::isFormatSupported(extension)) {
        setLoadingStatus("Loading " + extension.toUpper() + " file...");
        
        if (!AudioDecoder::loadAudioFile(actualPath, audioData)) {
            setLoading(false);
            setLoadingStatus("Ready");
            emit errorOccurred("Failed to load audio file: " + actualPath);
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

    currentFile_ = QFileInfo(actualPath).baseName();
    duration_ = audioData.getDuration();
    progress_ = 0.0;

    setLoading(false);
    setLoadingStatus("Ready");
    emit currentFileChanged();
    emit durationChanged();
    emit progressChanged();

    qDebug() << "File loaded successfully. Duration:" << duration_ << "seconds";
    return true;
}


void AudioManager::play() {
    if (!player_) {
        emit errorOccurred("Audio player not initialized");
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
            qDebug() << "Playback finished";
            progressTimer_->stop();
            emit isPlayingChanged();
        }
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
