import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    width: 1000
    height: 580
    visible: true
    title: "QR - Full"

    Rectangle {
        anchors.fill: parent
        color: "#c8e6c9"

        Image {
            id: image
            anchors.fill: parent
            source: "../../../Downloads/3e34cab5ff6b4b35127a.svg"
            fillMode: Image.PreserveAspectFit
        }
    }
}
