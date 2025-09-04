import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import AudioEngine 1.0

RowLayout {
    id: root
    property var audioManager
    spacing: 20

    Rectangle {
        width: 90
        height: 90
        radius: 6
        color: "#404040"

        Rectangle {
            anchors.fill: parent
            radius: 6
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1db954" }
                GradientStop { position: 0.5; color: "#1ed760" }
                GradientStop { position: 1.0; color: "#1aa34a" }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "🎵"
            color: "white"
            font.pointSize: 32
            font.family: "Arial"
            font.weight: Font.Bold
        }

        RotationAnimator on rotation {
            running: audioManager.isPlaying
            from: 0
            to: 360
            duration: 10000
            loops: Animation.Infinite
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 3
            anchors.leftMargin: 3
            radius: 6
            color: "black"
            opacity: 0.2
            z: -1
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: audioManager.currentFile || (audioManager.playlist.trackCount > 0 ? "Ready to play" : "No track selected")
            color: "white"
            font.pointSize: 18
            font.family: "Arial"
            font.weight: Font.Bold
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: "Unknown Artist"
            color: "#b3b3b3"
            font.pointSize: 14
            font.family: "Arial"
            font.weight: Font.Normal
        }

        Text {
            text: formatTime(audioManager.progress * audioManager.duration) + " / " + formatTime(audioManager.duration)
            color: "#b3b3b3"
            font.pointSize: 11
            font.family: "Arial"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 5
            color: "#404040"
            radius: 2.5

            Rectangle {
                width: parent.width * audioManager.progress
                height: parent.height
                radius: 2.5
                color: "#1db954"

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: "white"
                x: Math.max(0, Math.min(parent.width - width, parent.width * audioManager.progress - width/2))
                y: -3.5
                visible: audioManager.duration > 0

                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    color: "#1db954"
                }
            }
        }

        Text {
            text: audioManager.loadingStatus
            color: "#1db954"
            font.pointSize: 10
            font.family: "Arial"
            visible: audioManager.isLoading
        }
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}