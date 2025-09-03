import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import AudioEngine 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "Hi-Res Music Player"

    // Background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#2C3E50" }
            GradientStop { position: 1.0; color: "#34495E" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "🎵 Hi-Res Music Player"
            color: "white"
            font.pointSize: 24
            font.bold: true
        }

        // Current file info
        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: "#3C4C5C"
            radius: 10
            border.color: "#5C7C9C"
            border.width: 1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: audioManager.currentFile || "No file selected"
                    color: "white"
                    font.pointSize: 18
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: formatTime(audioManager.progress * audioManager.duration) + " / " + formatTime(audioManager.duration)
                    color: "#BDC3C7"
                    font.pointSize: 12
                }
            }
        }

        // Progress bar
        ProgressBar {
            Layout.fillWidth: true
            value: audioManager.progress
            from: 0
            to: 1

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 6
                color: "#34495E"
                radius: 3
            }

            contentItem: Item {
                implicitWidth: 200
                implicitHeight: 4

                Rectangle {
                    width: parent.parent.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: "#E74C3C"
                }
            }
        }

        // Control buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                id: loadButton
                text: "📁 Load File"
                onClicked: fileDialog.open()

                background: Rectangle {
                    color: parent.pressed ? "#2980B9" : "#3498DB"
                    radius: 5
                    border.color: "#2980B9"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: playButton
                text: audioManager.isPlaying ? "⏸️ Pause" : "▶️ Play"
                enabled: audioManager.currentFile !== ""
                onClicked: {
                    if (audioManager.isPlaying) {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                }

                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#27AE60" : "#2ECC71") : "#95A5A6"
                    radius: 5
                    border.color: parent.enabled ? "#27AE60" : "#7F8C8D"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: stopButton
                text: "⏹️ Stop"
                enabled: audioManager.currentFile !== ""
                onClicked: audioManager.stop()

                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#C0392B" : "#E74C3C") : "#95A5A6"
                    radius: 5
                    border.color: parent.enabled ? "#C0392B" : "#7F8C8D"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Audio devices info
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#3C4C5C"
            radius: 10
            border.color: "#5C7C9C"
            border.width: 1

            ScrollView {
                anchors.fill: parent
                anchors.margins: 10

                Column {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: "🔊 Available Audio Devices:"
                        color: "white"
                        font.pointSize: 14
                        font.bold: true
                    }

                    Repeater {
                        model: audioManager.getAudioDevices()

                        Text {
                            text: "• " + modelData
                            color: "#BDC3C7"
                            font.pointSize: 10
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }
        }
    }

    // File dialog
    FileDialog {
        id: fileDialog
        title: "Select Audio File"
        nameFilters: ["Audio files (*.wav)"]
        onAccepted: {
            console.log("Selected file:", selectedFile)
            audioManager.loadFile(selectedFile)
        }
    }

    // Error handling
    Connections {
        target: audioManager
        function onErrorOccurred(error) {
            errorDialog.text = error
            errorDialog.open()
        }
    }

    Dialog {
        id: errorDialog
        title: "❌ Error"
        property alias text: errorText.text

        Text {
            id: errorText
            color: "#E74C3C"
            wrapMode: Text.WordWrap
        }

        standardButtons: Dialog.Ok
    }

    // Helper functions
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00"

        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
