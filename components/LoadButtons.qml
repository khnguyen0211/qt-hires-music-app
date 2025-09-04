import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import AudioEngine 1.0

RowLayout {
    id: root
    property var audioManager
    spacing: 8

    Button {
        text: "Load Track"
        enabled: !audioManager.isLoading
        hoverEnabled: true
        flat: true
        focusPolicy: Qt.NoFocus
        down: false

        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 36
            radius: 18
            color: parent.enabled ? (parent.hovered ? "#1a1a1a" : "transparent") : "transparent"
            border.color: parent.enabled ? (parent.hovered ? "#1db954" : "#535353") : "#404040"
            border.width: 1
            opacity: parent.enabled ? 1.0 : 0.5

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        contentItem: Text {
            text: parent.text
            color: parent.enabled ? (parent.hovered ? "#1db954" : "#b3b3b3") : "#535353"
            font.pointSize: 12
            font.family: "Arial"
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        onClicked: fileDialog.open()
    }

    Button {
        text: "Load Playlist"
        enabled: !audioManager.isLoading
        hoverEnabled: true
        flat: true
        focusPolicy: Qt.NoFocus
        down: false

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 36
            radius: 18
            color: parent.enabled ? (parent.hovered ? "#1a1a1a" : "transparent") : "transparent"
            border.color: parent.enabled ? (parent.hovered ? "#1db954" : "#535353") : "#404040"
            border.width: 1
            opacity: parent.enabled ? 1.0 : 0.5

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        contentItem: Text {
            text: parent.text
            color: parent.enabled ? (parent.hovered ? "#1db954" : "#b3b3b3") : "#535353"
            font.pointSize: 12
            font.family: "Arial"
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        onClicked: playlistFileDialog.open()
    }

    FileDialog {
        id: fileDialog
        title: "Select Audio File"
        nameFilters: audioManager.getSupportedFormats()
        onAccepted: audioManager.loadFile(selectedFile)
    }

    FileDialog {
        id: playlistFileDialog
        title: "Add Files to Playlist"
        nameFilters: audioManager.getSupportedFormats()
        fileMode: FileDialog.OpenFiles
        onAccepted: audioManager.addMultipleToPlaylist(selectedFiles)
    }
}