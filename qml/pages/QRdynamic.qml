import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: qrWindow
    width: 1000
    height: 580
    visible: true
    color: "#152063"

    property string boxId: "box1"

    Image {
        anchors.centerIn: parent
        width: 496
        height: 406
        fillMode: Image.Tile
        source: boxManager.getQRImage(boxId)
        anchors.verticalCenterOffset: 72
        anchors.horizontalCenterOffset: -8
    }
    Label {
        x: 425
        y: 11
        text: "QRcode"
        font.pixelSize: 36
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        color: "white"
    }
    Label {
        id: label
        width: 321
        height: 95
        text: "📌Chú Ý\n-Quét QR để nhận hàng, đặt hàng.\n-Đặt Hàng vào thùng\Lấy hàng ra.\n-XIN VUI LÒNG ĐÓNG NẮP THÙNG. "
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 58   // khoảng cách từ trên xuống
        font.pixelSize: 20
        anchors.horizontalCenterOffset: -8      // chỉnh kích thước chữ
        color: "white"
    }
}
