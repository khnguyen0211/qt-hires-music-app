import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import AudioEngine 1.0

RowLayout {
    id: root
    property var audioManager
    spacing: 12

    Button {
        width: 56
        height: 56
        enabled: audioManager.playlist.hasPrevious && !audioManager.isLoading
        flat: true
        focusPolicy: Qt.NoFocus
        down: false

        background: Rectangle {
            radius: 28
            color: parent.enabled ? (parent.hovered ? "#282828" : "transparent") : "transparent"

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        hoverEnabled: true

        contentItem: Row {
            anchors.centerIn: parent
            spacing: 1

            Text {
                text: "◀◀"
                color: parent.parent.enabled ? (parent.parent.hovered ? "white" : "#b3b3b3") : "#535353"
                font.pointSize: 12
                font.family: "Arial"
                font.weight: Font.Bold

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        onClicked: audioManager.playPrevious()
    }

    Button {
        width: 56
        height: 56
        enabled: (audioManager.playlist.trackCount > 0 || audioManager.currentFile !== "") && !audioManager.isLoading
        flat: true
        focusPolicy: Qt.NoFocus
        down: false

        background: Rectangle {
            radius: 28
            color: parent.enabled ? (parent.hovered ? "#1ed760" : "#1db954") : "#535353"

            Behavior on color { ColorAnimation { duration: 150 } }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 2
                radius: 28
                color: "black"
                opacity: 0.3
                z: -1
            }
        }

        hoverEnabled: true

        contentItem: Text {
            text: audioManager.isPlaying ? "| |" : " ▶ "
            color: parent.enabled ? (parent.hovered ? "black" : "black") : "#b3b3b3"
            font.pointSize: audioManager.isPlaying ? 16 : 18
            font.family: "Arial"
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on font.pointSize { NumberAnimation { duration: 150 } }
        }

        onClicked: {
            if (audioManager.isPlaying) {
                audioManager.pause()
            } else {
                audioManager.play()
            }
        }
    }

    Button {
        width: 56
        height: 56
        enabled: audioManager.playlist.trackCount > 0 && !audioManager.isLoading
        flat: true
        focusPolicy: Qt.NoFocus
        down: false

        background: Rectangle {
            radius: 28
            color: parent.enabled ? (parent.hovered ? "#282828" : "transparent") : "transparent"

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        hoverEnabled: true

        contentItem: Text {
            text: "■"
            color: parent.enabled ? (parent.hovered ? "white" : "#b3b3b3") : "#535353"
            font.pointSize: 16
            font.family: "Arial"
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color { ColorAnimation { duration: 200 } }
        }

        onClicked: audioManager.stop()
    }

    Button {
        width: 56
        height: 56
        enabled: audioManager.playlist.hasNext && !audioManager.isLoading
        flat: true
        focusPolicy: Qt.NoFocus
        down: false

        onEnabledChanged: console.log("Next button enabled:", enabled, "hasNext:", audioManager.playlist.hasNext, "isLoading:", audioManager.isLoading)

        background: Rectangle {
            radius: 28
            color: parent.enabled ? (parent.hovered ? "#282828" : "transparent") : "transparent"

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        hoverEnabled: true

        contentItem: Row {
            anchors.centerIn: parent
            spacing: 1

            Text {
                text: "▶▶"
                color: parent.parent.enabled ? (parent.parent.hovered ? "white" : "#b3b3b3") : "#535353"
                font.pointSize: 12
                font.family: "Arial"
                font.weight: Font.Bold

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        onClicked: {
            console.log("Next button clicked - hasNext:", audioManager.playlist.hasNext, "currentIndex:", audioManager.playlist.currentIndex, "trackCount:", audioManager.playlist.trackCount)
            audioManager.playNext()
        }
    }
}