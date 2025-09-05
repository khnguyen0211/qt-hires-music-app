#include "track.h"
#include "audio_decoder.h"
#include <QUrl>

Track::Track(QObject* parent)
    : QObject(parent), duration_(0.0) {
}

Track::Track(const QString& filePath, QObject* parent)
    : QObject(parent), duration_(0.0) {
    setFilePath(filePath);
}

void Track::setFilePath(const QString& filePath) {
    QString actualPath = filePath;
    if (filePath.startsWith("file://")) {
        actualPath = QUrl(filePath).toLocalFile();
    }
    
    if (filePath_ != actualPath) {
        filePath_ = actualPath;
        updateFromFilePath();
        emit filePathChanged();
    }
}

void Track::setDuration(double duration) {
    if (duration_ != duration) {
        duration_ = duration;
        emit durationChanged();
    }
}

bool Track::isValid() const {
    return !filePath_.isEmpty() && QFileInfo::exists(filePath_);
}

void Track::updateFromFilePath() {
    if (filePath_.isEmpty()) {
        title_.clear();
        fileName_.clear();
        extension_.clear();
        duration_ = 0.0;
        emit titleChanged();
        emit fileNameChanged();
        emit extensionChanged();
        emit durationChanged();
        return;
    }

    QFileInfo fileInfo(filePath_);
    
    QString newFileName = fileInfo.baseName();
    if (fileName_ != newFileName) {
        fileName_ = newFileName;
        emit fileNameChanged();
    }

    QString newTitle = newFileName;
    if (title_ != newTitle) {
        title_ = newTitle;
        emit titleChanged();
    }

    QString newExtension = fileInfo.suffix().toLower();
    if (extension_ != newExtension) {
        extension_ = newExtension;
        emit extensionChanged();
    }
    
    double newDuration = AudioDecoder::getAudioDuration(filePath_);
    if (duration_ != newDuration) {
        duration_ = newDuration;
        emit durationChanged();
        qDebug() << "Track duration calculated:" << filePath_ << "→" << newDuration << "seconds";
    }
}
