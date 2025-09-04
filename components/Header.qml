import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 64
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#1db954"
        opacity: 0.1
        radius: 8
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 16

        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: "#1db954"

            Text {
                anchors.centerIn: parent
                text: "🎵"
                color: "white"
                font.pointSize: 20
                font.family: "Arial"
                font.weight: Font.Bold
            }
        }

        Text {
            text: "Hi-Res Music Player"
            color: "white"
            font.pointSize: 24
            font.family: "Arial"
            font.weight: Font.Bold
            Layout.fillWidth: true
        }

        Text {
            text: "Premium Quality Audio"
            color: "#b3b3b3"
            font.pointSize: 12
            font.family: "Arial"
            font.weight: Font.Normal
        }
    }
}