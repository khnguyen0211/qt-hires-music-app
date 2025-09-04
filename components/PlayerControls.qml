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

        Item {
            Layout.fillWidth: true
            height: 5
            
            property bool isDragging: false
            property double seekPosition: 0.0
            property bool wasPlayingBeforeDrag: false
            
            Rectangle {
                id: trackBackground
                anchors.fill: parent
                color: "#404040"
                radius: 2.5
                
                Rectangle {
                    id: progressBar
                    width: parent.width * (parent.isDragging ? parent.seekPosition : audioManager.progress)
                    height: parent.height
                    radius: 2.5
                    color: "#1db954"
                    
                    Behavior on width {
                        enabled: !parent.isDragging
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }
                
                Rectangle {
                    id: handle
                    width: parent.isDragging ? 16 : 12
                    height: parent.isDragging ? 16 : 12
                    radius: width / 2
                    color: "white"
                    x: Math.max(0, Math.min(parent.width - width, 
                        (parent.isDragging ? parent.seekPosition : audioManager.progress) * parent.width - width/2))
                    y: parent.isDragging ? -5.5 : -3.5
                    visible: audioManager.duration > 0
                    opacity: parent.isDragging ? 1.0 : (mouseArea.containsMouse ? 1.0 : 0.8)
                    
                    // Drop shadow when dragging
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.topMargin: parent.isDragging ? 2 : 0
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        color: "black"
                        opacity: parent.isDragging ? 0.3 : 0.0
                        z: -1
                        
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on anchors.topMargin { NumberAnimation { duration: 150 } }
                    }
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.isDragging ? 10 : 8
                        height: parent.isDragging ? 10 : 8
                        radius: width / 2
                        color: "#1db954"
                        
                        Behavior on width { NumberAnimation { duration: 150 } }
                        Behavior on height { NumberAnimation { duration: 150 } }
                    }
                    
                    Behavior on x {
                        enabled: !parent.isDragging
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on width { NumberAnimation { duration: 150 } }
                    Behavior on height { NumberAnimation { duration: 150 } }
                    Behavior on y { NumberAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
                
                // Scrub tooltip
                Rectangle {
                    id: scrubTooltip
                    visible: parent.isDragging
                    width: scrubText.implicitWidth + 12
                    height: scrubText.implicitHeight + 8
                    color: "#333333"
                    radius: 4
                    opacity: 0.9
                    
                    x: Math.max(4, Math.min(parent.width - width - 4, 
                        parent.seekPosition * parent.width - width/2))
                    y: -height - 12
                    
                    Text {
                        id: scrubText
                        anchors.centerIn: parent
                        color: "white"
                        font.pointSize: 10
                        font.family: "Arial"
                        font.weight: Font.Bold
                        text: formatTime(parent.seekPosition * audioManager.duration)
                    }
                    
                    // Small arrow pointing down
                    Rectangle {
                        width: 6
                        height: 6
                        color: parent.color
                        rotation: 45
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.bottom
                        anchors.topMargin: -3
                    }
                    
                    Behavior on x { NumberAnimation { duration: 50 } }
                }
            }
            
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: parent.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                
                property bool wasDragging: false
                property bool isDragActive: false
                property real startMouseX: 0
                
                onPressed: {
                    if (audioManager.duration > 0) {
                        isDragActive = true
                        startMouseX = mouseX
                        parent.isDragging = true
                        parent.seekPosition = Math.max(0, Math.min(1, mouseX / width))
                        wasDragging = false
                        
                        // Lưu trạng thái và pause audio nếu đang phát
                        parent.wasPlayingBeforeDrag = audioManager.isPlaying
                        if (audioManager.isPlaying) {
                            audioManager.pause()
                        }
                    }
                }
                
                onPositionChanged: {
                    if (isDragActive && audioManager.duration > 0) {
                        // Calculate new position (chỉ update UI, không seek)
                        var newPosition = Math.max(0, Math.min(1, mouseX / width))
                        parent.seekPosition = newPosition
                        
                        // Mark as dragging if moved significantly from start position
                        if (Math.abs(mouseX - startMouseX) > 3) {
                            wasDragging = true
                            // Không seek trong lúc drag để tránh tiếng ồn
                        }
                    }
                }
                
                onReleased: {
                    if (isDragActive && audioManager.duration > 0) {
                        // Seek to final position
                        audioManager.seek(parent.seekPosition)
                        
                        // Khôi phục audio nếu đang phát trước khi drag
                        if (parent.wasPlayingBeforeDrag) {
                            audioManager.play()
                        }
                        
                        // Reset drag state
                        parent.isDragging = false
                        isDragActive = false
                        wasDragging = false
                        parent.wasPlayingBeforeDrag = false
                    }
                }
                
                // Handle click vs drag distinction
                onClicked: {
                    // Only handle click if it wasn't a drag operation
                    if (!wasDragging && audioManager.duration > 0) {
                        var position = Math.max(0, Math.min(1, mouseX / width))
                        audioManager.seek(position)
                    }
                }
                
                // Prevent context menu
                onPressAndHold: {
                    // Do nothing to prevent context menu
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