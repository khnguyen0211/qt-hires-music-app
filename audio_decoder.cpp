#include "audio_decoder.h"
#include <QProcess>
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <fstream>
#include <cstring>

QStringList AudioDecoder::getSupportedFormats() {
    QStringList formats;
    
    if (isFfmpegAvailable()) {
        formats << "All Audio Files (*.wav *.mp3 *.flac *.m4a *.m4r *.aac *.ac3 *.aif *.alac *.ogg *.opus *.wma)"
                << "WAV Files (*.wav)"
                << "MP3 Files (*.mp3)" 
                << "FLAC Files (*.flac)"
                << "M4A Files (*.m4a)"
                << "M4R Files (*.m4r)"
                << "AAC Files (*.aac)"
                << "AC3 Files (*.ac3)"
                << "AIF/AIFF Files (*.aif *.aiff)"
                << "ALAC Files (*.alac)"
                << "OGG Files (*.ogg)"
                << "Opus Files (*.opus)"
                << "WMA Files (*.wma)";
    } else {
        formats << "WAV Files (*.wav)";
    }
    
    return formats;
}

bool AudioDecoder::isFormatSupported(const QString& extension) {
    return supportedExtensions().contains(extension.toLower());
}

bool AudioDecoder::loadAudioFile(const QString& filePath, AudioData& audioData) {
    audioData.reset();
    
    QString extension = QFileInfo(filePath).suffix().toLower();
    
    if (extension == "wav") {
        return loadWavFile(filePath, audioData);
    } else if (isFormatSupported(extension) && isFfmpegAvailable()) {
        return loadWithFfmpeg(filePath, audioData);
    }
    
    qDebug() << "Unsupported format:" << extension;
    return false;
}

bool AudioDecoder::loadWavFile(const QString& filePath, AudioData& audioData) {
    std::ifstream file(filePath.toStdString().c_str(), std::ios::binary);
    if (!file.is_open()) {
        qDebug() << "Cannot open file:" << filePath;
        return false;
    }

    char riffHeader[12];
    file.read(riffHeader, 12);
    if (!file || strncmp(riffHeader, "RIFF", 4) != 0 || strncmp(riffHeader + 8, "WAVE", 4) != 0) {
        qDebug() << "Invalid WAV format";
        return false;
    }

    char chunkId[4];
    uint32_t chunkSize;
    bool foundFmt = false, foundData = false;
    uint32_t dataSize = 0;
    
    while (!foundFmt || !foundData) {
        file.read(chunkId, 4);
        file.read(reinterpret_cast<char*>(&chunkSize), 4);
        
        if (!file) {
            qDebug() << "Unexpected end of file";
            return false;
        }

        if (strncmp(chunkId, "fmt ", 4) == 0) {
            if (chunkSize < 16) {
                qDebug() << "Invalid fmt chunk size";
                return false;
            }

            char fmtData[16];
            file.read(fmtData, 16);
            if (!file) return false;

            uint16_t audioFormat = *reinterpret_cast<uint16_t*>(fmtData);
            audioData.channels = *reinterpret_cast<uint16_t*>(fmtData + 2);
            audioData.sampleRate = *reinterpret_cast<uint32_t*>(fmtData + 4);
            uint16_t bitsPerSample = *reinterpret_cast<uint16_t*>(fmtData + 14);

            if (audioFormat != 1 || bitsPerSample != 16) {
                qDebug() << "Only 16-bit PCM WAV files are supported";
                return false;
            }

            foundFmt = true;
            if (chunkSize > 16) {
                file.seekg(chunkSize - 16, std::ios::cur);
            }
            
        } else if (strncmp(chunkId, "data", 4) == 0) {
            dataSize = chunkSize;
            foundData = true;
            break;
        } else {
            file.seekg(chunkSize, std::ios::cur);
        }
    }

    if (!foundFmt || !foundData || dataSize == 0) {
        qDebug() << "Missing required WAV chunks or invalid data size";
        return false;
    }

    audioData.totalFrames = dataSize / (audioData.channels * 2);
    audioData.samples.resize(dataSize / 2);

    file.read(reinterpret_cast<char*>(audioData.samples.data()), dataSize);
    
    return file.good();
}

bool AudioDecoder::loadWithFfmpeg(const QString& filePath, AudioData& audioData) {
    if (!isFfmpegAvailable()) {
        return false;
    }

    QString tempWavPath = QDir::temp().absoluteFilePath("temp_audio.wav");
    
    QProcess ffmpegProcess;
    QStringList arguments;
    arguments << "-i" << filePath
              << "-acodec" << "pcm_s16le"
              << "-ar" << "44100"
              << "-ac" << "2"
              << "-f" << "wav"
              << "-y"
              << tempWavPath;

    QString ffmpegPath = QCoreApplication::applicationDirPath() + "/ffmpeg.exe";
    ffmpegProcess.start(ffmpegPath, arguments);
    
    if (!ffmpegProcess.waitForFinished(30000) || ffmpegProcess.exitCode() != 0) {
        qDebug() << "FFmpeg conversion failed";
        return false;
    }

    if (!QFile::exists(tempWavPath)) {
        qDebug() << "Temporary WAV file was not created";
        return false;
    }

    bool success = loadWavFile(tempWavPath, audioData);
    QFile::remove(tempWavPath);
    
    return success;
}

bool AudioDecoder::isFfmpegAvailable() {
    QString ffmpegPath = QCoreApplication::applicationDirPath() + "/ffmpeg.exe";
    
    QProcess process;
    process.start(ffmpegPath, QStringList() << "-version");
    process.waitForFinished(3000);
    
    return process.exitCode() == 0;
}

const QStringList& AudioDecoder::supportedExtensions() {
    static const QStringList extensions = {
        "wav", "mp3", "flac", "m4a", "m4r", "aac", "ac3", 
        "aif", "aiff", "alac", "ogg", "opus", "wma"
    };
    return extensions;
}

double AudioDecoder::getAudioDuration(const QString& filePath) {
    if (!QFileInfo::exists(filePath)) {
        qDebug() << "File does not exist:" << filePath;
        return 0.0;
    }

    QString extension = QFileInfo(filePath).suffix().toLower();
    
    // Chỉ load minimal data để tính duration, không load toàn bộ samples
    AudioData tempData;
    
    if (extension == "wav") {
        // Có thể optimize để chỉ đọc header WAV
        if (loadWavFile(filePath, tempData)) {
            return tempData.getDuration();
        }
    } else if (isFfmpegAvailable()) {
        // Sử dụng FFmpeg để get duration nhanh hơn
        if (loadWithFfmpeg(filePath, tempData)) {
            return tempData.getDuration();
        }
    }
    
    qDebug() << "Failed to get duration for:" << filePath;
    return 0.0;
}