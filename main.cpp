#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "audiomanager.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("Hi-Res Music Player");
    app.setApplicationVersion("1.0");

    QQmlApplicationEngine engine;

    qmlRegisterType<AudioManager>("AudioEngine", 1, 0, "AudioManager");

    AudioManager audioManager;
    engine.rootContext()->setContextProperty("audioManager", &audioManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("HiResMusicApp", "Main");

    return app.exec();
}
