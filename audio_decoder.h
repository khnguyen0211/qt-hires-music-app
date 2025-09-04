#ifndef AUDIO_DECODER_H
#define AUDIO_DECODER_H

#include <QString>
#include <QStringList>
#include <vector>
#include <cstdint>

struct AudioData {
    std::vector<int16_t> samples;
    size_t totalFrames;
    int channels;
    unsigned int sampleRate;

    AudioData() : totalFrames(0), channels(0), sampleRate(0) {}

    void reset() {
        samples.clear();
        totalFrames = 0;
        channels = 0;
        sampleRate = 0;
    }

    bool isValid() const {
        return totalFrames > 0 && sampleRate > 0 && !samples.empty();
    }

    double getDuration() const {
        return sampleRate > 0 ? static_cast<double>(totalFrames) / sampleRate : 0.0;
    }
};

class AudioDecoder {
public:
    static QStringList getSupportedFormats();
    static bool isFormatSupported(const QString& extension);
    static bool loadAudioFile(const QString& filePath, AudioData& audioData);
    static double getAudioDuration(const QString& filePath);

private:
    static bool loadWavFile(const QString& filePath, AudioData& audioData);
    static bool loadWithFfmpeg(const QString& filePath, AudioData& audioData);
    static bool isFfmpegAvailable();
    static const QStringList& supportedExtensions();
};

#endif // AUDIO_DECODER_H