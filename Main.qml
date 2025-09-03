import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import AudioEngine 1.0

ApplicationWindow {
    id: window
    width: 1000
    height: 750
    visible: true
    title: "Hi-Res Music Player"
    color: "black"

    // Set minimum size to prevent UI from breaking
    minimumWidth: 900
    minimumHeight: 650

    // Spotify-inspired dark background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.3; color: "#121212" }
            GradientStop { position: 1.0; color: "#191414" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // 1. HEADER - App Title (Spotify style)
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

        // 2. PLAYER AREA - Music Controls (Spotify-inspired)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            color: "#181818"
            radius: 12

            Rectangle {
                anchors.fill: parent
                color: "#282828"
                opacity: 0.3
                radius: 12
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Track info and controls row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    // Album art (Spotify style)
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

                        // Subtle shadow effect
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

                    // Track info (Spotify style)
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

                            // Progress handle
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
                }

                // Controls section (compact)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // File buttons (smaller)
                    RowLayout {
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
                            text: "Add to Playlist"
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
                    }

                    Item { Layout.fillWidth: true } // Spacer

                    // Playback controls (smaller)
                    RowLayout {
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

                                // Shadow effect
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

                            // Debug the button state
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
                }
            }
        }

        // 3. PLAYLIST SECTION (Spotify-inspired)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 380
            color: "#121212"
            radius: 12

            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                opacity: 0.5
                radius: 12
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                // Playlist header (Spotify style)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Playlist"
                        color: "white"
                        font.pointSize: 20
                        font.family: "Arial"
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: Math.max(40, countText.implicitWidth + 16)
                        height: 28
                        radius: 14
                        color: "#1db954"

                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text: audioManager.playlist.trackCount.toString() + " songs"
                            color: "black"
                            font.pointSize: 11
                            font.family: "Arial"
                            font.weight: Font.Bold
                        }
                    }

                    Button {
                        width: 36
                        height: 36
                        enabled: audioManager.playlist.trackCount > 0
                        flat: true
                        focusPolicy: Qt.NoFocus
                        down: false

                        background: Rectangle {
                            radius: 18
                            color: "transparent"
                            border.color: parent.enabled ? (parent.hovered ? "white" : "#b3b3b3") : "#535353"
                            border.width: 1

                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }

                        hoverEnabled: true

                        contentItem: Text {
                            text: "×"
                            color: parent.enabled ? (parent.hovered ? "white" : "#b3b3b3") : "#535353"
                            font.pointSize: 16
                            font.family: "Arial"
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            Behavior on color { ColorAnimation { duration: 150 } }
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
                            height: 64
                            radius: 8
                            color: isCurrent ? "#1db954" : (hoverArea.containsMouse ? "#282828" : "transparent")

                            Behavior on color { ColorAnimation { duration: 200 } }

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
                                    width: 36
                                    height: 36
                                    radius: 4
                                    color: isCurrent ? "black" : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: (index + 1).toString()
                                        color: isCurrent ? "#1db954" : "#b3b3b3"
                                        font.pointSize: 14
                                        font.family: "Arial"
                                        font.weight: Font.Bold
                                    }
                                }

                                // Track info - more detailed
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    // Track title - Spotify style
                                    Text {
                                        text: title
                                        color: isCurrent ? "black" : "white"
                                        font.pointSize: 16
                                        font.family: "Arial"
                                        font.weight: isCurrent ? Font.Bold : Font.Normal
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    // File info and duration - Spotify style
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Rectangle {
                                            width: formatText.implicitWidth + 12
                                            height: 20
                                            radius: 10
                                            color: isCurrent ? "black" : "#282828"

                                            Text {
                                                id: formatText
                                                anchors.centerIn: parent
                                                text: extension.toUpperCase()
                                                color: isCurrent ? "#1db954" : "#b3b3b3"
                                                font.pointSize: 9
                                                font.family: "Arial"
                                                font.weight: Font.Bold
                                            }
                                        }

                                        Text {
                                            text: "•"
                                            color: isCurrent ? "black" : "#535353"
                                            font.pointSize: 12
                                            font.family: "Arial"
                                        }

                                        Text {
                                            text: hoverArea.containsMouse ? "Double-click to play" : "Song"
                                            color: isCurrent ? "black" : "#b3b3b3"
                                            font.pointSize: 11
                                            font.family: "Arial"
                                            font.weight: Font.Normal

                                            Behavior on color { ColorAnimation { duration: 200 } }
                                        }

                                        Item { Layout.fillWidth: true }

                                        // Duration if available
                                        Text {
                                            text: duration > 0 ? formatTime(duration) : "--:--"
                                            color: isCurrent ? "black" : "#b3b3b3"
                                            font.pointSize: 12
                                            font.family: "Arial"
                                            font.weight: Font.Normal
                                        }
                                    }
                                }

                                // Play indicator - Spotify style
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: "black"
                                    visible: isCurrent && audioManager.isPlaying

                                    Text {
                                        anchors.centerIn: parent
                                        text: "♪"
                                        color: "#1db954"
                                        font.pointSize: 16
                                        font.family: "Arial"
                                        font.weight: Font.Bold
                                    }

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        running: parent.visible
                                        NumberAnimation { to: 0.6; duration: 800 }
                                        NumberAnimation { to: 1.0; duration: 800 }
                                    }
                                }

                                // Static status for paused tracks
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: "black"
                                    visible: isCurrent && !audioManager.isPlaying

                                    Text {
                                        anchors.centerIn: parent
                                        text: "| |"
                                        color: "#1db954"
                                        font.pointSize: 12
                                        font.family: "Arial"
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state - Spotify style
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: audioManager.playlist.trackCount === 0

                    Column {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -70
                        spacing: 16

                        Text {
                            text: "🎵"
                            font.pointSize: 48
                            font.family: "Arial"
                            color: "#535353"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Your playlist is empty"
                            color: "white"
                            font.pointSize: 18
                            font.family: "Arial"
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Add some tracks to get the party started"
                            color: "#b3b3b3"
                            font.pointSize: 12
                            font.family: "Arial"
                            font.weight: Font.Normal
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 160
                            height: 48
                            flat: true
                            focusPolicy: Qt.NoFocus
                            down: false

                            background: Rectangle {
                                radius: 24
                                color: parent.hovered ? "#1ed760" : "#1db954"

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            hoverEnabled: true

                            contentItem: Text {
                                text: "Browse files"
                                color: "black"
                                font.pointSize: 14
                                font.family: "Arial"
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: playlistFileDialog.open()
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
    }

    // Loading overlay - Spotify style
    Rectangle {
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

    // Helper function
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
