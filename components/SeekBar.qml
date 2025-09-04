import QtQuick
import QtQuick.Controls
import AudioEngine 1.0

Item {
    id: root
    property var audioManager
    property bool isDragging: false
    property double seekPosition: 0.0
    
    height: 5
    
    Rectangle {
        id: trackBackground
        anchors.fill: parent
        color: "#404040"
        radius: 2.5
        
        Rectangle {
            id: progressBar
            width: parent.width * (root.isDragging ? root.seekPosition : audioManager.progress)
            height: parent.height
            radius: 2.5
            color: "#1db954"
            
            Behavior on width {
                enabled: !root.isDragging
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
        
        Rectangle {
            id: handle
            width: 12
            height: 12
            radius: 6
            color: "white"
            x: Math.max(0, Math.min(parent.width - width, 
                (root.isDragging ? root.seekPosition : audioManager.progress) * parent.width - width/2))
            y: -3.5
            visible: audioManager.duration > 0
            
            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 4
                color: "#1db954"
            }
            
            Behavior on x {
                enabled: !root.isDragging
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        property bool wasDragging: false
        
        onPressed: {
            if (audioManager.duration > 0) {
                root.isDragging = true
                root.seekPosition = Math.max(0, Math.min(1, mouseX / width))
                mouseArea.wasDragging = false
            }
        }
        
        onPositionChanged: {
            if (root.isDragging && audioManager.duration > 0) {
                root.seekPosition = Math.max(0, Math.min(1, mouseX / width))
                mouseArea.wasDragging = true
            }
        }
        
        onReleased: {
            if (root.isDragging && audioManager.duration > 0) {
                audioManager.seek(root.seekPosition)
                root.isDragging = false
                mouseArea.wasDragging = false
            }
        }
        
        onClicked: {
            if (!mouseArea.wasDragging && audioManager.duration > 0) {
                var position = Math.max(0, Math.min(1, mouseX / width))
                audioManager.seek(position)
            }
        }
    }
    
    Rectangle {
        id: tooltip
        visible: mouseArea.containsMouse && audioManager.duration > 0
        color: "#333333"
        radius: 4
        opacity: 0.8
        width: tooltipText.implicitWidth + 8
        height: tooltipText.implicitHeight + 8
        
        Text {
            id: tooltipText
            anchors.centerIn: parent
            color: "white"
            font.pointSize: 10
            font.family: "Arial"
            text: formatTime(tooltip.hoverPosition * audioManager.duration)
        }
        
        property double hoverPosition: mouseArea.containsMouse ? 
            Math.max(0, Math.min(1, mouseArea.mouseX / mouseArea.width)) : 0
        
        x: Math.max(0, Math.min(root.width - width, mouseArea.mouseX - width/2))
        y: -height - 8
        
        function formatTime(seconds) {
            if (isNaN(seconds) || seconds < 0) return "00:00"
            var mins = Math.floor(seconds / 60)
            var secs = Math.floor(seconds % 60)
            return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
        }
    }
}