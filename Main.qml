import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import AudioEngine 1.0

import "components"

ApplicationWindow {
    id: window
    width: 1000
    height: 750
    visible: true
    visibility: Window.FullScreen
    title: "Hi-Res Music Player"
    color: "black"

    minimumWidth: 900
    minimumHeight: 650

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.3; color: "#121212" }
            GradientStop { position: 1.0; color: "#191414" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Header {
            id: header
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            color: "#181818"
            radius: 12

            Rectangle {
                anchors.fill: parent
                color: "#282828"
                opacity: 0.3
                radius: 12
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                PlayerControls {
                    id: playerControls
                    audioManager: window.audioManager
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    LoadButtons {
                        id: loadButtons
                        audioManager: window.audioManager
                    }

                    Item { Layout.fillWidth: true }

                    PlaybackButtons {
                        id: playbackButtons
                        audioManager: window.audioManager
                    }
                }
            }
        }

        PlaylistView {
            id: playlistView
            audioManager: window.audioManager
        }
    }

    property alias audioManager: audioEngine

    AudioManager {
        id: audioEngine
    }


    ErrorDialog {
        id: errorDialog
        audioManager: audioEngine
    }

    LoadingOverlay {
        id: loadingOverlay
        audioManager: audioEngine
    }
}
