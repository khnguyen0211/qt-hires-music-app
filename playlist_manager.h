#ifndef PLAYLIST_MANAGER_H
#define PLAYLIST_MANAGER_H

#include <QObject>
#include <QStringList>
#include <QAbstractListModel>
#include <vector>
#include <memory>
#include "track.h"

class PlaylistManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(int trackCount READ trackCount NOTIFY trackCountChanged)
    Q_PROPERTY(bool hasNext READ hasNext NOTIFY currentIndexChanged)
    Q_PROPERTY(bool hasPrevious READ hasPrevious NOTIFY currentIndexChanged)

public:
    enum PlaylistRoles {
        TitleRole = Qt::UserRole + 1,
        FilePathRole,
        FileNameRole,
        ExtensionRole,
        DurationRole,
        IsCurrentRole
    };

    explicit PlaylistManager(QObject* parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Playlist operations
    Q_INVOKABLE void addTrack(const QString& filePath);
    Q_INVOKABLE void addTracks(const QStringList& filePaths);
    Q_INVOKABLE void removeTrack(int index);
    Q_INVOKABLE void clearPlaylist();
    Q_INVOKABLE void moveTrack(int fromIndex, int toIndex);

    // Navigation
    Q_INVOKABLE bool next();
    Q_INVOKABLE bool previous();
    Q_INVOKABLE bool setCurrentIndex(int index);

    // Properties
    int currentIndex() const { return currentIndex_; }
    int trackCount() const { return static_cast<int>(tracks_.size()); }
    bool hasNext() const;
    bool hasPrevious() const;

    // Current track access
    Track* currentTrack() const;
    QString currentFilePath() const;

signals:
    void currentIndexChanged();
    void trackCountChanged();
    void trackAdded(int index);
    void trackRemoved(int index);
    void playlistCleared();

private:
    void updateCurrentTrack();

    std::vector<std::unique_ptr<Track>> tracks_;
    int currentIndex_;
};

#endif // PLAYLIST_MANAGER_H