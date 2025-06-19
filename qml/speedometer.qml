// Speedometer.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 400
    height: 400

    property int speed: 0  // tốc độ hiện tại (0-180)
    property real angle: -135 + (speed / 180.0) * 270

    Rectangle {
        anchors.centerIn: parent
        width: 200
        height: 200
        radius: 150
        color: "#222"
        border.color: "white"
        border.width: 4
        anchors.verticalCenterOffset: 7
        anchors.horizontalCenterOffset: 5

        Repeater {
            model: 19
            delegate: Rectangle {
                width: 2
                height: index % 3 === 0 ? 20 : 10
                color: "white"
                anchors.centerIn: parent
                transform: [
                    Rotation {
                        origin.x: 0
                        origin.y: 90
                        angle: -135 + index * (270 / 18)
                    },
                    Translate { y: -85 }
                ]
            }
        }

        Rectangle {
            width: 4
            height: 100
            color: "#14da6c"
            radius: 2
            anchors.centerIn: parent
            transform: Rotation {
                origin.x: 2
                origin.y: 100
                angle: angle
            }
        }

        Text {
            text: speed + " km/h"
            font.pixelSize: 25
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            speed = (speed + 1) % 181
        }
    }
}
