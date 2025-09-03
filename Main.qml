import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import AudioEngine 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 700
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
            text: "Hi-Res Music Player"
            color: "white"
            font.pointSize: 24
            font.bold: true
        }

        // Format Support Info
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: audioManager.isFfmpegAvailable ? "#27AE60" : "#E67E22"
            radius: 8

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: audioManager.isFfmpegAvailable ? "✓" : "!"
                    color: "white"
                    font.pointSize: 16
                    font.bold: true
                }

                Text {
                    text: audioManager.isFfmpegAvailable
                        ? "Multi-format support enabled (MP3, FLAC, M4A, AAC, AC3, AIF, ALAC, OGG, Opus, WMA, etc.)"
                        : "Limited to WAV only - Install FFmpeg for more formats"
                    color: "white"
                    font.pointSize: 12
                    font.bold: true
                }
            }
        }

        // Current file info
        Rectangle {
            Layout.fillWidth: true
            height: 120
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

                // Loading status
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: audioManager.loadingStatus
                    color: audioManager.isLoading ? "#F39C12" : "#95A5A6"
                    font.pointSize: 10
                    visible: audioManager.isLoading || audioManager.loadingStatus !== "Ready"
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
                implicitHeight: 8
                color: "#34495E"
                radius: 4
            }

            contentItem: Item {
                implicitWidth: 200
                implicitHeight: 6

                Rectangle {
                    width: parent.parent.visualPosition * parent.width
                    height: parent.height
                    radius: 3
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
                text: "Load File"
                enabled: !audioManager.isLoading
                onClicked: fileDialog.open()

                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#2980B9" : "#3498DB") : "#95A5A6"
                    radius: 5
                    border.color: parent.enabled ? "#2980B9" : "#7F8C8D"
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
                text: audioManager.isPlaying ? "Pause" : "Play"
                enabled: audioManager.currentFile !== "" && !audioManager.isLoading
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
                text: "Stop"
                enabled: audioManager.currentFile !== "" && !audioManager.isLoading
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

        // Audio devices and formats info
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
                    spacing: 15

                    Text {
                        text: "Available Audio Devices:"
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

                    Text {
                        text: "Supported Formats:"
                        color: "white"
                        font.pointSize: 14
                        font.bold: true
                    }

                    Repeater {
                        model: audioManager.getSupportedFormats()

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

    // File dialog với multi-format support
    FileDialog {
        id: fileDialog
        title: "Select Audio File"
        nameFilters: audioManager.getSupportedFormats()
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
        title: "Error"
        property alias text: errorText.text

        Text {
            id: errorText
            color: "#E74C3C"
            wrapMode: Text.WordWrap
            width: 300
        }

        standardButtons: Dialog.Ok
    }

    // Loading overlay
    Rectangle {
        anchors.fill: parent
        color: "#80000000"  // Semi-transparent black
        visible: false

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: audioManager.isLoading
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: audioManager.loadingStatus
                color: "white"
                font.pointSize: 14
            }
        }
    }

    // Helper functions
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00"

        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
