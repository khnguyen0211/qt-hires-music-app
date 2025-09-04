import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import AudioEngine 1.0

Rectangle {
    id: root
    property var audioManager
    
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

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: title
                                color: isCurrent ? "black" : "white"
                                font.pointSize: 16
                                font.family: "Arial"
                                font.weight: isCurrent ? Font.Bold : Font.Normal
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

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

                                Text {
                                    text: duration > 0 ? formatTime(duration) : "--:--"
                                    color: isCurrent ? "black" : "#b3b3b3"
                                    font.pointSize: 12
                                    font.family: "Arial"
                                    font.weight: Font.Normal
                                }
                            }
                        }

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

                    onClicked: emptyStateFileDialog.open()
                }
            }
        }
    }

    FileDialog {
        id: emptyStateFileDialog
        title: "Add Files to Playlist"
        nameFilters: audioManager.getSupportedFormats()
        fileMode: FileDialog.OpenFiles
        onAccepted: audioManager.addMultipleToPlaylist(selectedFiles)
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}