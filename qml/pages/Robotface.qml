import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1000
    height: 580
    color: "#121E2A"
    property string emotion: "happy"
    signal robotClicked

    Item {
        id: eyes
        width: 280
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 130
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: eyeLeft
            width: 208
            height: 252
            radius: 30
            color: "#4fc3f7"
            anchors.left: parent.left
            anchors.leftMargin: -120
            anchors.verticalCenterOffset: 49
            anchors.verticalCenter: parent.verticalCenter
            transform: [
                Scale {
                    id: scaleLeft
                    origin.x: 0
                    origin.y: 0
                    xScale: 1.0
                    yScale: 1.0
                },
                Translate {
                    id: transLeft
                    x: 0
                    y: 0
                }
            ]
        }

        Rectangle {
            id: eyeRight
            width: 208
            height: 252
            radius: 30
            color: "#4FC3F7"
            anchors.right: parent.right
            anchors.rightMargin: -118
            anchors.verticalCenterOffset: 49
            anchors.verticalCenter: parent.verticalCenter
            transform: [
                Scale {
                    id: scaleRight
                    origin.x: 0
                    origin.y: 0
                    xScale: 1.0
                    yScale: 1.0
                },
                Translate {
                    id: transRight
                    x: 0
                    y: 0
                }
            ]
        }

        Timer {
            id: blinkTimer
            interval: 3500
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
                    duration: 100
                }
                PropertyAnimation {
                    target: scaleRight
                    property: "yScale"
                    to: 0.1
                    duration: 100
                }
            }
            PauseAnimation {
                duration: 80
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: scaleLeft
                    property: "yScale"
                    to: 1.0
                    duration: 100
                }
                PropertyAnimation {
                    target: scaleRight
                    property: "yScale"
                    to: 1.0
                    duration: 100
                }
            }
        }

        Timer {
            id: lookTimer
            interval: 2000
            running: true
            repeat: true
            onTriggered: eyes.lookAround()
        }

        function lookAround() {
            var dir = Math.floor(Math.random() * 4); // 0=trái, 1=phải, 2=lên, 3=xuống

            if (dir === 0) {
                // Trái
                scaleLeft.origin.x = 0;
                scaleRight.origin.x = 0;
                scaleLeft.xScale = 0.7;
                scaleRight.xScale = 0.7;
                transLeft.x = eyeLeft.width * 0.3;
                transRight.x = eyeRight.width * 0.3;
            } else if (dir === 1) {
                // Phải
                scaleLeft.origin.x = 0;
                scaleRight.origin.x = 0;
                scaleLeft.xScale = 0.7;
                scaleRight.xScale = 0.7;
                transLeft.x = -eyeLeft.width * 0.3;
                transRight.x = -eyeRight.width * 0.3;
            } else if (dir === 2) {
                // Lên: bo dưới lớn
                eyeLeft.radius = 100;
                eyeRight.radius = 100;
            } else {
                // Xuống: bo trên lớn
                eyeLeft.radius = 100;
                eyeRight.radius = 100;
            }

            Qt.createQmlObject("import QtQuick 2.0; Timer { interval: 1500; running: true; repeat: false; onTriggered: eyes.resetEyes() }", eyes, "resetTimer");
        }

        function resetEyes() {
            scaleLeft.xScale = 1.0;
            scaleLeft.yScale = 1.0;
            scaleRight.xScale = 1.0;
            scaleRight.yScale = 1.0;

            transLeft.x = 0;
            transLeft.y = 0;
            transRight.x = 0;
            transRight.y = 0;

            eyeLeft.radius = 30;
            eyeRight.radius = 30;

            scaleLeft.origin.x = 0;
            scaleRight.origin.x = 0;
            scaleLeft.origin.y = 0;
            scaleRight.origin.y = 0;
        }
    }

    Canvas {
        id: mouth
        y: 401
        width: 534
        height: 118
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 61
        anchors.horizontalCenter: parent.horizontalCenter

        property string mouthShape: "smile"
        property int count: 0

        property var shapes: ["circle", "triangle", "rectangle", "square", "trapezoid", "parallelogram", "hexagon", "pentagon", "line", "curve"]

        Timer {
            id: shapeTimer
            interval: 200
            running: true
            repeat: true
            onTriggered: {
                mouth.mouthShape = mouth.shapes[mouth.count];
                mouth.requestPaint();

                mouth.count += 1;

                if (mouth.count >= mouth.shapes.length) {
                    shapeTimer.stop();
                    delayTimer.start();
                    mouth.mouthShape = "smile";
                    mouth.requestPaint();
                }
            }
        }

        Timer {
            id: delayTimer
            interval: 3000
            running: false
            repeat: false
            onTriggered: {
                mouth.count = 0;
                shapeTimer.start();
            }
        }

        Component.onCompleted: mouth.requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (mouth.mouthShape === "smile") {
                ctx.strokeStyle = "#4FC3F7";
                ctx.lineWidth = 4;
                ctx.beginPath();
                ctx.arc(width / 2, height / 2, 40, 0, Math.PI, false);
                ctx.stroke();
            } else {
                ctx.fillStyle = "#4FC3F7";
                ctx.strokeStyle = "#4FC3F7";
                ctx.lineWidth = 4;
                ctx.beginPath();

                switch (mouth.mouthShape) {
                case "circle":
                    ctx.arc(width / 2, height / 2, 30, 0, Math.PI * 2, false);
                    break;
                case "triangle":
                    ctx.moveTo(width / 2, height / 2 - 30);
                    ctx.lineTo(width / 2 - 30, height / 2 + 30);
                    ctx.lineTo(width / 2 + 30, height / 2 + 30);
                    ctx.closePath();
                    break;
                case "rectangle":
                    ctx.rect(width / 2 - 40, height / 2 - 20, 80, 40);
                    break;
                case "square":
                    ctx.rect(width / 2 - 30, height / 2 - 30, 60, 60);
                    break;
                case "trapezoid":
                    ctx.moveTo(width / 2 - 40, height / 2 - 20);
                    ctx.lineTo(width / 2 + 40, height / 2 - 20);
                    ctx.lineTo(width / 2 + 30, height / 2 + 20);
                    ctx.lineTo(width / 2 - 30, height / 2 + 20);
                    ctx.closePath();
                    break;
                case "parallelogram":
                    ctx.moveTo(width / 2 - 40, height / 2 - 20);
                    ctx.lineTo(width / 2 + 20, height / 2 - 20);
                    ctx.lineTo(width / 2 + 40, height / 2 + 20);
                    ctx.lineTo(width / 2 - 20, height / 2 + 20);
                    ctx.closePath();
                    break;
                case "hexagon":
                    for (var i = 0; i < 6; i++) {
                        var angle = Math.PI / 3 * i - Math.PI / 2;
                        var x = width / 2 + 30 * Math.cos(angle);
                        var y = height / 2 + 30 * Math.sin(angle);
                        if (i === 0) {
                            ctx.moveTo(x, y);
                        } else {
                            ctx.lineTo(x, y);
                        }
                    }
                    ctx.closePath();
                    break;
                case "pentagon":
                    for (var i = 0; i < 5; i++) {
                        var angle = (2 * Math.PI / 5) * i - Math.PI / 2;
                        var x = width / 2 + 30 * Math.cos(angle);
                        var y = height / 2 + 30 * Math.sin(angle);
                        if (i === 0) {
                            ctx.moveTo(x, y);
                        } else {
                            ctx.lineTo(x, y);
                        }
                    }
                    ctx.closePath();
                    break;
                case "line":
                    ctx.moveTo(width / 2 - 30, height / 2);
                    ctx.lineTo(width / 2 + 30, height / 2);
                    break;
                case "curve":
                    ctx.moveTo(width / 2 - 40, height / 2);
                    ctx.quadraticCurveTo(width / 2, height / 2 + 40, width / 2 + 40, height / 2);
                    break;
                }

                if (mouth.mouthShape === "line" || mouth.mouthShape === "curve") {
                    ctx.stroke();
                } else {
                    ctx.fill();
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: robotClicked()
    }
}
