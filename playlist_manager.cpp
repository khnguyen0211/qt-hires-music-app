#include "playlist_manager.h"
#include "audio_decoder.h"
#include <QDebug>
#include <QFileInfo>

PlaylistManager::PlaylistManager(QObject* parent)
    : QAbstractListModel(parent), currentIndex_(-1) {
}

int PlaylistManager::rowCount(const QModelIndex& parent) const {
    Q_UNUSED(parent)
    return static_cast<int>(tracks_.size());
}

QVariant PlaylistManager::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= static_cast<int>(tracks_.size())) {
        return QVariant();
    }

    const auto& track = tracks_[index.row()];
    
    switch (role) {
    case TitleRole:
        return track->title();
    case FilePathRole:
        return track->filePath();
    case FileNameRole:
        return track->fileName();
    case ExtensionRole:
        return track->extension();
    case DurationRole:
        return track->duration();
    case IsCurrentRole:
        return index.row() == currentIndex_;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PlaylistManager::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[FilePathRole] = "filePath";
    roles[FileNameRole] = "fileName";
    roles[ExtensionRole] = "extension";
    roles[DurationRole] = "duration";
    roles[IsCurrentRole] = "isCurrent";
    return roles;
}

void PlaylistManager::addTrack(const QString& filePath) {
    if (!AudioDecoder::isFormatSupported(QFileInfo(filePath).suffix().toLower())) {
        qDebug() << "Unsupported format:" << filePath;
        return;
    }

    beginInsertRows(QModelIndex(), static_cast<int>(tracks_.size()), static_cast<int>(tracks_.size()));
    
    auto track = std::make_unique<Track>(filePath, this);
    tracks_.push_back(std::move(track));
    
    endInsertRows();

    emit trackAdded(static_cast<int>(tracks_.size()) - 1);
    emit trackCountChanged();

    // Set first track as current if playlist was empty (only for single track add)
    if (tracks_.size() == 1 && currentIndex_ == -1) {
        qDebug() << "Setting first track as current";
        setCurrentIndex(0);
    }

    qDebug() << "Track added:" << filePath;
    
    // Emit currentIndexChanged to update hasNext/hasPrevious properties
    emit currentIndexChanged();
}

void PlaylistManager::addTracks(const QStringList& filePaths) {
    bool wasEmpty = tracks_.empty();
    int originalCurrentIndex = currentIndex_;
    
    // Temporarily disable currentIndex setting during batch add
    bool wasCurrentIndexSet = false;
    
    for (const QString& filePath : filePaths) {
        if (!AudioDecoder::isFormatSupported(QFileInfo(filePath).suffix().toLower())) {
            qDebug() << "Unsupported format:" << filePath;
            continue;
        }

        beginInsertRows(QModelIndex(), static_cast<int>(tracks_.size()), static_cast<int>(tracks_.size()));
        
        auto track = std::make_unique<Track>(filePath, this);
        tracks_.push_back(std::move(track));
        
        endInsertRows();

        emit trackAdded(static_cast<int>(tracks_.size()) - 1);
        emit trackCountChanged();

        qDebug() << "Track added:" << filePath;
    }
    
    // Set current index only once after all tracks are added
    if (wasEmpty && !tracks_.empty() && originalCurrentIndex == -1) {
        qDebug() << "Setting current index to 0 after adding all tracks to empty playlist";
        setCurrentIndex(0);
    }
    
    qDebug() << "Added" << filePaths.size() << "tracks. Current index:" << currentIndex_ << "Track count:" << tracks_.size();
    
    // Emit currentIndexChanged to update hasNext/hasPrevious properties
    emit currentIndexChanged();
}

void PlaylistManager::removeTrack(int index) {
    if (index < 0 || index >= static_cast<int>(tracks_.size())) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    
    tracks_.erase(tracks_.begin() + index);
    
    endRemoveRows();

    // Adjust current index if needed
    if (index == currentIndex_) {
        if (tracks_.empty()) {
            currentIndex_ = -1;
        } else if (currentIndex_ >= static_cast<int>(tracks_.size())) {
            currentIndex_ = static_cast<int>(tracks_.size()) - 1;
        }
        emit currentIndexChanged();
    } else if (index < currentIndex_) {
        currentIndex_--;
        emit currentIndexChanged();
    }

    emit trackRemoved(index);
    emit trackCountChanged();

    qDebug() << "Track removed at index:" << index;
}

void PlaylistManager::clearPlaylist() {
    if (tracks_.empty()) {
        return;
    }

    beginResetModel();
    tracks_.clear();
    currentIndex_ = -1;
    endResetModel();

    emit playlistCleared();
    emit trackCountChanged();
    emit currentIndexChanged();

    qDebug() << "Playlist cleared";
}

void PlaylistManager::moveTrack(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= static_cast<int>(tracks_.size()) ||
        toIndex < 0 || toIndex >= static_cast<int>(tracks_.size()) ||
        fromIndex == toIndex) {
        return;
    }

    beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), 
                  toIndex > fromIndex ? toIndex + 1 : toIndex);

    auto track = std::move(tracks_[fromIndex]);
    tracks_.erase(tracks_.begin() + fromIndex);
    tracks_.insert(tracks_.begin() + toIndex, std::move(track));

    // Update current index if affected
    if (fromIndex == currentIndex_) {
        currentIndex_ = toIndex;
    } else if (fromIndex < currentIndex_ && toIndex >= currentIndex_) {
        currentIndex_--;
    } else if (fromIndex > currentIndex_ && toIndex <= currentIndex_) {
        currentIndex_++;
    }

    endMoveRows();
    emit currentIndexChanged();

    qDebug() << "Track moved from" << fromIndex << "to" << toIndex;
}

bool PlaylistManager::next() {
    qDebug() << "PlaylistManager::next() called";
    if (!hasNext()) {
        qDebug() << "next() failed - hasNext() returned false";
        return false;
    }
    
    qDebug() << "next() calling setCurrentIndex(" << (currentIndex_ + 1) << ")";
    return setCurrentIndex(currentIndex_ + 1);
}

bool PlaylistManager::previous() {
    if (!hasPrevious()) {
        return false;
    }
    
    return setCurrentIndex(currentIndex_ - 1);
}

bool PlaylistManager::setCurrentIndex(int index) {
    if (index < -1 || index >= static_cast<int>(tracks_.size())) {
        return false;
    }

    if (currentIndex_ != index) {
        int oldIndex = currentIndex_;
        currentIndex_ = index;
        
        // Update model data for old and new current tracks
        if (oldIndex >= 0) {
            QModelIndex oldModelIndex = createIndex(oldIndex, 0);
            emit dataChanged(oldModelIndex, oldModelIndex, {IsCurrentRole});
        }
        
        if (currentIndex_ >= 0) {
            QModelIndex newModelIndex = createIndex(currentIndex_, 0);
            emit dataChanged(newModelIndex, newModelIndex, {IsCurrentRole});
        }
        
        emit currentIndexChanged();
        qDebug() << "Current track index changed to:" << currentIndex_;
    }
    
    return true;
}

bool PlaylistManager::hasNext() const {
    bool result = currentIndex_ >= 0 && currentIndex_ < static_cast<int>(tracks_.size()) - 1;
    qDebug() << "hasNext() called - currentIndex_:" << currentIndex_ << "tracks_.size():" << tracks_.size() << "result:" << result;
    return result;
}

bool PlaylistManager::hasPrevious() const {
    return currentIndex_ > 0;
}

Track* PlaylistManager::currentTrack() const {
    if (currentIndex_ >= 0 && currentIndex_ < static_cast<int>(tracks_.size())) {
        return tracks_[currentIndex_].get();
    }
    return nullptr;
}

QString PlaylistManager::currentFilePath() const {
    Track* track = currentTrack();
    return track ? track->filePath() : QString();
}