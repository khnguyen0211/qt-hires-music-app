import QtQuick
import QtQuick.Controls
import AudioEngine 1.0

Rectangle {
    id: root
    property var audioManager
    
    anchors.fill: parent
    color: "#aa000000"
    visible: audioManager.isLoading

    Rectangle {
        anchors.centerIn: parent
        width: 320
        height: 140
        radius: 16
        color: "#181818"

        Rectangle {
            anchors.fill: parent
            color: "#282828"
            opacity: 0.3
            radius: 16
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: audioManager.isLoading
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: audioManager.loadingStatus
                color: "white"
                font.pointSize: 16
                font.family: "Arial"
                font.weight: Font.Normal
            }
        }
    }
}