#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "audiomanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Register AudioManager với QML
    qmlRegisterType<AudioManager>("AudioEngine", 1, 0, "AudioManager");

    // Tạo instance AudioManager và expose ra QML context
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
