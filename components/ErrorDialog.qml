import QtQuick
import QtQuick.Controls
import AudioEngine 1.0

Dialog {
    id: root
    property var audioManager
    property alias text: errorText.text
    
    title: "Error"

    background: Rectangle {
        color: "#181818"
        radius: 12
        border.color: "#e22134"
        border.width: 1
    }

    Text {
        id: errorText
        color: "#ff6b6b"
        font.pointSize: 13
        font.family: "Arial"
        font.weight: Font.Normal
        wrapMode: Text.WordWrap
        width: 320
    }

    standardButtons: Dialog.Ok

    Connections {
        target: audioManager
        function onErrorOccurred(error) {
            root.text = error
            root.open()
        }
    }
}