import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import AudioEngine 1.0

ApplicationWindow {
    id: window
    width: 900
    height: 700
    visible: true
    title: "Hi-Res Music Player"
    color: "#1a1a1a"
    
    // Set minimum size to prevent UI from breaking
    minimumWidth: 800
    minimumHeight: 600

    // Clean dark background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#2d2d2d" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        // 1. HEADER - App Title (1/10 ratio)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#2a2a2a"
            radius: 12
            border.color: "#4a4a4a"
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1db954" }
                        GradientStop { position: 1.0; color: "#1ed760" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: "white"
                        font.pointSize: 18
                        font.bold: true
                    }
                }

                Text {
                    text: "Hi-Res Music Player"
                    color: "#ffffff"
                    font.pointSize: 20
                    font.weight: Font.Bold
                }
            }
        }

        // 2. PLAYER AREA - Music Controls (2/10 ratio)  
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: "#2a2a2a"
            radius: 16
            border.color: "#4a4a4a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Track info and controls row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    // Album art (smaller)
                    Rectangle {
                        width: 80
                        height: 80
                        radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#1db954" }
                            GradientStop { position: 1.0; color: "#1ed760" }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "♪"
                            color: "white"
                            font.pointSize: 28
                            font.weight: Font.Bold
                        }

                        RotationAnimator on rotation {
                            running: audioManager.isPlaying
                            from: 0
                            to: 360
                            duration: 8000
                            loops: Animation.Infinite
                        }
                    }

                    // Track info (compact)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: audioManager.currentFile || (audioManager.playlist.trackCount > 0 ? "Ready to play" : "No track selected")
                            color: "#ffffff"
                            font.pointSize: 16
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: formatTime(audioManager.progress * audioManager.duration) + " / " + formatTime(audioManager.duration)
                            color: "#b3b3b3"
                            font.pointSize: 12
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            color: "#404040"
                            radius: 2

                            Rectangle {
                                width: parent.width * audioManager.progress
                                height: parent.height
                                radius: 2
                                color: "#1db954"

                                Behavior on width {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                        }

                        Text {
                            text: audioManager.loadingStatus
                            color: "#ffa726"
                            font.pointSize: 10
                            visible: audioManager.isLoading
                        }
                    }
                }

                // Controls section (compact)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // File buttons (smaller)
                    RowLayout {
                        spacing: 8

                        Button {
                            text: "Load"
                            enabled: !audioManager.isLoading
                            
                            background: Rectangle {
                                implicitWidth: 80
                                implicitHeight: 32
                                radius: 16
                                color: parent.enabled ? (parent.hovered ? "#1ed760" : "#1db954") : "#404040"
                                border.color: parent.enabled ? "#1ed760" : "#606060"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#888888"
                                font.pointSize: 11
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: fileDialog.open()
                        }

                        Button {
                            text: "Add"
                            enabled: !audioManager.isLoading
                            
                            background: Rectangle {
                                implicitWidth: 80
                                implicitHeight: 32
                                radius: 16
                                color: parent.enabled ? (parent.hovered ? "#2196f3" : "#1976d2") : "#404040"
                                border.color: parent.enabled ? "#2196f3" : "#606060"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#888888"
                                font.pointSize: 11
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: playlistFileDialog.open()
                        }
                    }

                    Item { Layout.fillWidth: true } // Spacer

                    // Playback controls (smaller)
                    RowLayout {
                        spacing: 12

                        Button {
                            width: 48
                            height: 48
                            enabled: audioManager.playlist.hasPrevious && !audioManager.isLoading
                            
                            background: Rectangle {
                                radius: 24
                                color: parent.enabled ? (parent.hovered ? "#404040" : "#333333") : "#2a2a2a"
                                border.color: parent.enabled ? "#606060" : "#404040"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            contentItem: Text {
                                text: "⏮"
                                color: parent.enabled ? "white" : "#666666"
                                font.pointSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: audioManager.playPrevious()
                        }

                        Button {
                            width: 60
                            height: 60
                            enabled: (audioManager.playlist.trackCount > 0 || audioManager.currentFile !== "") && !audioManager.isLoading
                            
                            background: Rectangle {
                                radius: 30
                                color: parent.enabled ? (parent.hovered ? "#1ed760" : "#1db954") : "#404040"
                                border.color: parent.enabled ? "#1ed760" : "#606060"
                                border.width: 2

                                Behavior on scale { NumberAnimation { duration: 100 } }
                                scale: parent.pressed ? 0.95 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            contentItem: Text {
                                text: audioManager.isPlaying ? "⏸" : "▶"
                                color: parent.enabled ? "white" : "#888888"
                                font.pointSize: 22
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
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
                            width: 48
                            height: 48
                            enabled: audioManager.playlist.trackCount > 0 && !audioManager.isLoading
                            
                            background: Rectangle {
                                radius: 24
                                color: parent.enabled ? (parent.hovered ? "#f44336" : "#d32f2f") : "#404040"
                                border.color: parent.enabled ? "#f44336" : "#606060"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            contentItem: Text {
                                text: "⏹"
                                color: parent.enabled ? "white" : "#888888"
                                font.pointSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: audioManager.stop()
                        }

                        Button {
                            width: 48
                            height: 48
                            enabled: audioManager.playlist.hasNext && !audioManager.isLoading
                            
                            // Debug the button state
                            onEnabledChanged: console.log("Next button enabled:", enabled, "hasNext:", audioManager.playlist.hasNext, "isLoading:", audioManager.isLoading)
                            
                            background: Rectangle {
                                radius: 24
                                color: parent.enabled ? (parent.hovered ? "#404040" : "#333333") : "#2a2a2a"
                                border.color: parent.enabled ? "#606060" : "#404040"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            contentItem: Text {
                                text: "⏭"
                                color: parent.enabled ? "white" : "#666666"
                                font.pointSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                console.log("Next button clicked - hasNext:", audioManager.playlist.hasNext, "currentIndex:", audioManager.playlist.currentIndex, "trackCount:", audioManager.playlist.trackCount)
                                audioManager.playNext()
                            }
                        }
                    }
                }
            }
        }

        // 3. PLAYLIST SECTION (7/10 ratio - Main content area)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 350
            color: "#2a2a2a"
            radius: 16
            border.color: "#4a4a4a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                // Playlist header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Playlist"
                        color: "#ffffff"
                        font.pointSize: 16
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 60
                        height: 32
                        radius: 16
                        color: "#1db954"
                        
                        Text {
                            anchors.centerIn: parent
                            text: audioManager.playlist.trackCount.toString()
                            color: "white"
                            font.pointSize: 14
                            font.weight: Font.Bold
                        }
                    }

                    Button {
                        width: 44
                        height: 44
                        enabled: audioManager.playlist.trackCount > 0
                        
                        background: Rectangle {
                            radius: 22
                            color: parent.enabled ? (parent.hovered ? "#f44336" : "#d32f2f") : "#404040"
                            border.color: parent.enabled ? "#f44336" : "#606060"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        
                        contentItem: Text {
                            text: "✕"
                            color: parent.enabled ? "white" : "#888888"
                            font.pointSize: 16
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: audioManager.playlist.clearPlaylist()
                    }
                }

                // Playlist view
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: playlistView
                        model: audioManager.playlist
                        spacing: 8

                        delegate: Rectangle {
                            width: playlistView.width
                            height: 60
                            radius: 12
                            color: isCurrent ? "#1db954" : (hoverArea.containsMouse ? "#353535" : "#333333")
                            border.color: isCurrent ? "#1ed760" : (hoverArea.containsMouse ? "#555555" : "#404040")
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onDoubleClicked: {
                                    audioManager.playTrackAt(index)
                                    if (!audioManager.isPlaying) {
                                        audioManager.play()
                                    }
                                }
                                cursorShape: Qt.PointingHandCursor
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                // Track number with status
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: isCurrent ? "white" : "#444444"
                                    border.color: isCurrent ? "#1ed760" : "#555555"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: (index + 1).toString()
                                        color: isCurrent ? "#1db954" : "#ffffff"
                                        font.pointSize: 12
                                        font.weight: Font.Bold
                                    }
                                }

                                // Track info - more detailed
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    // Track title - larger and more prominent
                                    Text {
                                        text: title
                                        color: isCurrent ? "white" : "#ffffff"
                                        font.pointSize: 14
                                        font.weight: isCurrent ? Font.Bold : Font.Medium
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    // File info and duration
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            width: formatText.implicitWidth + 8
                                            height: 16
                                            radius: 8
                                            color: isCurrent ? "#e8f5e8" : "#404040"

                                            Text {
                                                id: formatText
                                                anchors.centerIn: parent
                                                text: extension.toUpperCase()
                                                color: isCurrent ? "#1db954" : "#b3b3b3"
                                                font.pointSize: 8
                                                font.weight: Font.Bold
                                            }
                                        }

                                        Text {
                                            text: "•"
                                            color: "#666666"
                                            font.pointSize: 10
                                        }

                                        Text {
                                            text: "Double-click to play"
                                            color: isCurrent ? "#e8f5e8" : "#888888"
                                            font.pointSize: 9
                                            font.weight: Font.Italic
                                        }

                                        Item { Layout.fillWidth: true }

                                        // Duration if available
                                        Text {
                                            text: duration > 0 ? formatTime(duration) : "--:--"
                                            color: isCurrent ? "#e8f5e8" : "#b3b3b3"
                                            font.pointSize: 10
                                            font.weight: Font.Medium
                                        }
                                    }
                                }

                                // Play indicator - enhanced
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: "white"
                                    visible: isCurrent && audioManager.isPlaying
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "♪"
                                        color: "#1db954"
                                        font.pointSize: 12
                                        font.weight: Font.Bold
                                    }

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        running: parent.visible
                                        NumberAnimation { to: 0.5; duration: 1000 }
                                        NumberAnimation { to: 1.0; duration: 1000 }
                                    }
                                }

                                // Static status for paused tracks
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: "#666666"
                                    visible: isCurrent && !audioManager.isPlaying
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "⏸"
                                        color: "white"
                                        font.pointSize: 10
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: audioManager.playlist.trackCount === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        Text {
                            text: "🎵"
                            font.pointSize: 48
                            color: "#666666"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Your playlist is empty"
                            color: "#888888"
                            font.pointSize: 18
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Click \"Add to Playlist\" to get started"
                            color: "#666666"
                            font.pointSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    // File dialogs
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

    // Error dialog
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
        
        background: Rectangle {
            color: "#333333"
            radius: 12
            border.color: "#d32f2f"
            border.width: 2
        }

        Text {
            id: errorText
            color: "#f44336"
            font.pointSize: 12
            wrapMode: Text.WordWrap
            width: 300
        }

        standardButtons: Dialog.Ok
    }

    // Loading overlay
    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        visible: audioManager.isLoading

        Rectangle {
            anchors.centerIn: parent
            width: 300
            height: 120
            radius: 16
            color: "#333333"
            border.color: "#1db954"
            border.width: 2

            Column {
                anchors.centerIn: parent
                spacing: 16

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: audioManager.isLoading
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: audioManager.loadingStatus
                    color: "#ffffff"
                    font.pointSize: 14
                    font.weight: Font.Medium
                }
            }
        }
    }

    // Helper function
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
