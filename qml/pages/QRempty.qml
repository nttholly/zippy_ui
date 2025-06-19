import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    width: 1000
    height: 580
    visible: true
    title: "QR - Empty"

    Rectangle {
        id: rectangle
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        color: "#ffcdd2"

        Image {
            id: image
            anchors.fill: parent
            source: "../../../Downloads/3e34cab5ff6b4b35127a.jpg"
            fillMode: Image.PreserveAspectFit
        }
    }
}
