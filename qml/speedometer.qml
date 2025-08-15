import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Item {
    id: speedometer
    width: 400
    height: 300

    property int speed: 0         // 0 - 240 km/h
    property int maxSpeed: 240
    property real rpm: 0.0        // 0.0 - 10.0 (x1000 rpm)
    property real maxRPM: 10.0
    property int overspeedLimit: 120

    Rectangle {
        anchors.fill: parent
        color: "#000c0c0c"
        radius: 20
        border.color: "#0000ffff"
        border.width: 2
    }

    // Vòng cung hiển thị tốc độ
    Canvas {
        id: arcCanvas
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        width: parent.width * 0.9
        height: 100
        onPaint: {
            let ctx = arcCanvas.getContext("2d");
            ctx.clearRect(0, 0, width, height);

            let centerX = width / 2;
            let centerY = height;
            let radius = 90;
            let startAngle = Math.PI;
            let endAngle = Math.PI * (1 + (speed / maxSpeed));

            // Nền vòng cung
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, Math.PI, 2 * Math.PI);
            ctx.lineWidth = 12;
            ctx.strokeStyle = "#222";
            ctx.stroke();

            // Vòng cung tốc độ
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
            ctx.lineWidth = 12;
            ctx.strokeStyle = "#90ee90";
            ctx.stroke();
        }

        Connections {
            target: speedometer
            function onSpeedChanged() {
                arcCanvas.requestPaint();
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Tốc độ hiển thị
        Row {
            spacing: 5
            Text {
                id: speedText
                text: Number(speed).toFixed(0)
                font.pixelSize: 64
                font.bold: true
                color: "#90ee90"
                font.family: "Orbitron"
            }
            Text {
                text: "km/h"
                font.pixelSize: 24
                color: "#90ee90"
                font.family: "Orbitron"
            }
        }

        // Thanh tốc độ
        Rectangle {
            width: parent.width
            height: 12
            radius: 6
            color: "#222"

            Rectangle {
                width: parent.width * (speed / maxSpeed)
                height: parent.height
                radius: 6
                color: "#90ee90"
                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
    Image {
        id: carImage
        source: "../images/svg_images/delivery_truck_speed_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
        width: 80
        height: 40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        // Vị trí ban đầu
        x: -width

        PropertyAnimation {
            id: carAnim
            target: carImage
            property: "x"
            from: 20
            to: speedometer.width - 100
            duration: 4000
            easing.type: Easing.Linear
            running: speed > 1
            onRunningChanged: {
                if (!running && speed > 1) {
                    start(); // Khi xong → chạy lại
                }
            }
        }

        // Khi speed > 1 thì start
        Connections {
            target: speedometer
            function onSpeedChanged() {
                if (speed > 1 && !carAnim.running) {
                    carAnim.start();
                }
            }
        }
    }
    Timer {
        interval: 100   // 100 ms
        running: true
        repeat: true
        onTriggered: {
            if (speed < maxSpeed) {
                speed += 1;
            } else {
                speed = 0; // Reset lại nếu muốn lặp
            }
        }
    }
}
