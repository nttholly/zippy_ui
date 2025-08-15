import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 400
    height: 300
    color: "#0012192a"

    property string speechText: "Xin chào!"

    // --- Mắt ---
    Item {
        id: eyes
        width: 280
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 65
        anchors.horizontalCenterOffset: 6
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: eyeLeft
            width: 90
            height: 110
            radius: 30
            color: "#4FC3F7"
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenterOffset: -27
            anchors.verticalCenter: parent.verticalCenter

            transform: Scale {
                id: scaleLeft
                yScale: 1.0
            }
        }

        Rectangle {
            id: eyeRight
            x: 183
            width: 90
            height: 110
            radius: 30
            color: "#4FC3F7"
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenterOffset: -22
            anchors.verticalCenter: parent.verticalCenter

            transform: Scale {
                id: scaleRight
                yScale: 1.0
            }
        }

        Timer {
            interval: 4000
            running: true
            repeat: true
            onTriggered: blinkAnim.start()
        }

        SequentialAnimation {
            id: blinkAnim
            ParallelAnimation {
                PropertyAnimation {
                    target: scaleLeft
                    property: "yScale"
                    to: 0.1
                    duration: 80
                }
                PropertyAnimation {
                    target: scaleRight
                    property: "yScale"
                    to: 0.1
                    duration: 80
                }
            }
            PauseAnimation {
                duration: 50
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: scaleLeft
                    property: "yScale"
                    to: 1.0
                    duration: 80
                }
                PropertyAnimation {
                    target: scaleRight
                    property: "yScale"
                    to: 1.0
                    duration: 80
                }
            }
        }
    }

    // --- Miệng ---
    Canvas {
        id: mouth
        width: 74
        height: 81
        anchors.top: eyes.bottom
        anchors.topMargin: 6
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        property real mouthSize: 30

        Timer {
            interval: 300
            running: true
            repeat: true
            onTriggered: {
                mouth.mouthSize = (mouth.mouthSize === 30) ? 45 : 30;
                mouth.requestPaint();
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = "#4FC3F7";
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, mouth.mouthSize / 2, 0, Math.PI * 2);
            ctx.fill();
        }
    }
    Connections {
        target: boxManager
        function onBoxAlert(boxId, message) {
            if (boxId === "box1") {
                alertLabel.text = message;
                alertLabel.visible = true;
            } else if (boxId === "box2") {
                alertLabel.text = message;
                alertLabel.visible = true;
            }
        }
    }

    // --- Văn bản ---
    Text {
        color: "#ffffff"
        text: "Hello I'm ZIPPY!"
        font.pixelSize: 18
        anchors.top: mouth.bottom
        anchors.topMargin: -51
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Text.Wrap
        anchors.horizontalCenterOffset: 103
    }
}
