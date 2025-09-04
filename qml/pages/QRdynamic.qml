import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: qrWindow
    width: 1000
    height: 580
    color: "#152063"
    visible: true

    // nhận payload khi Loader.setSource("pages/QRdynamic.qml", { initialPayload: payload })
    property var initialPayload: null
    property string boxId: "box1"   // dùng nếu muốn fallback gọi boxManager.getQRImage(boxId)

    Image {
        id: qrImage
        anchors.centerIn: parent
        width: 496
        height: 406
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenterOffset: 72
        anchors.horizontalCenterOffset: -8
        onStatusChanged: console.log("[QR] image status=", status, "src.len=", source ? source.length : 0)
    }

    Label {
        x: 425; y: 11
        text: "QRcode"
        font.pixelSize: 36
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        color: "white"
    }

    Label {
        id: note
        width: 321; height: 95
        text: "📌Chú Ý\n-Quét QR để nhận hàng, đặt hàng.\n-Đặt Hàng vào thùng/Lấy hàng ra.\n-XIN VUI LÒNG ĐÓNG NẮP THÙNG."
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 58
        anchors.horizontalCenterOffset: -8
        font.pixelSize: 20
        color: "white"
    }

    // 1 = HIỂN THỊ, 0 = TẮT
    function applyQrPayload(payload) {
        if (!payload) return;
        var st = Number(payload.status);

        // Ưu tiên ảnh file local (do backend lưu sẵn)
        if (payload._local_qr_file) {
            var srcFile = "file://" + payload._local_qr_file + "?t=" + Date.now();
            console.log("[QR] apply local file, status=", st, "file=", srcFile);
            qrImage.source = srcFile;
            qrWindow.visible = (st === 1);
            if (st === 0) qrImage.source = "";
            return;
        }

        // Fallback: base64
        var b64 = (payload.qrCode || payload.qr_code || payload["qr-code"] || "");
        b64 = b64 ? b64.toString().replace(/\s/g, "") : "";

        if (st === 1 && b64.length > 0) {
            var src = "data:image/png;base64," + b64;
            if (qrImage.source === src) {        // ép reload nếu trùng
                qrImage.source = "";
                Qt.callLater(function(){ qrImage.source = src; });
            } else {
                qrImage.source = src;
            }
            qrWindow.visible = true;
        } else if (st === 0) {
            qrWindow.visible = false;
            qrImage.source = "";
        }
    }

    // Khi component lên: ưu tiên initialPayload; nếu không có thì fallback gọi boxManager
    Component.onCompleted: {
        if (initialPayload) {
            applyQrPayload(initialPayload);
        } else {
            // Fallback: dùng boxManager từ context (KHÔNG khai báo property boxManager để khỏi che khuất)
            if (typeof boxManager !== "undefined" && boxManager && boxManager.getQRImage) {
                var src = boxManager.getQRImage(boxId);
                if (src && src.length > 0) qrImage.source = src;
            } else {
                console.warn("[QR] boxManager unavailable; waiting for MQTT /qr-code …");
            }
        }
    }

    // Cập nhật theo MQTT
    Connections {
        target: mqttClient
        function onMessageReceived(topic, payload) {
            if (!topic.endsWith("/qr-code")) return;
            applyQrPayload(payload);
        }
    }
}
