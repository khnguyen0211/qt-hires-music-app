#ifndef TRACK_H
#define TRACK_H

#include <QString>
#include <QFileInfo>
#include <QObject>

class Track : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged)
    Q_PROPERTY(QString extension READ extension NOTIFY extensionChanged)
    Q_PROPERTY(double duration READ duration NOTIFY durationChanged)

public:
    explicit Track(QObject* parent = nullptr);
    explicit Track(const QString& filePath, QObject* parent = nullptr);

    QString title() const { return title_; }
    QString filePath() const { return filePath_; }
    QString fileName() const { return fileName_; }
    QString extension() const { return extension_; }
    double duration() const { return duration_; }

    void setFilePath(const QString& filePath);
    void setDuration(double duration);

    bool isValid() const;

signals:
    void titleChanged();
    void filePathChanged();
    void fileNameChanged();
    void extensionChanged();
    void durationChanged();

private:
    void updateFromFilePath();

    QString title_;
    QString filePath_;
    QString fileName_;
    QString extension_;
    double duration_;
};

#endif // TRACK_H