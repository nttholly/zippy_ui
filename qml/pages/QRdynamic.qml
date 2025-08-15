import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    id: qrWindow
    width: 1000
    height: 580
    visible: true
    color: "white"
    title: "QR Code"

    property string boxId: "box1"

    Image {
        anchors.centerIn: parent
        width: 200
        height: 200
        fillMode: Image.PreserveAspectFit
        source: boxManager.getQRImage(boxId)
    }
}
