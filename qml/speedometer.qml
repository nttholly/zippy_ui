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
