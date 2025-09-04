import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 952
    height: 538
    color: "#152063"
    radius: 8

    // Số log tối đa giữ lại
    property int maxLogs: 100

    // Model lưu log
    ListModel {
        id: logModel
    }

    // Map màu theo topic
    function colorForTopic(t) {
        if (!t)
            return "#CDE6FF";
        if (t.endsWith("/trip/state"))
            return "#7CFFB2";   // xanh mint
        if (t.endsWith("/heartbeat"))
            return "#00E676";   // xanh alive
        if (t.endsWith("/location"))
            return "#4FC3F7";   // xanh dương nhạt
        if (t.endsWith("/status"))
            return "#FFD166";   // vàng
        if (t.endsWith("/container"))
            return "#FF6B6B";   // đỏ coral
        if (t.endsWith("/qr-code"))
            return "#B388FF";   // tím QR
        return "#CDE6FF";                                  // mặc định
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                text: "MQTT Debug (last " + root.maxLogs + " messages)"
                color: "white"
                font.pixelSize: 18
                Layout.fillWidth: true
            }
            Button {
                text: "Clear"
                onClicked: logModel.clear()
            }
        }

        // Danh sách log
        ListView {
            id: logView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: logModel
            clip: true
            cacheBuffer: 2000

            delegate: Rectangle {
                width: logView.width
                height: Math.max(52, payloadText.paintedHeight + 18 + 18)
                color: "transparent"

                // viền trái theo màu topic
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    color: root.colorForTopic(topic)
                    radius: 2
                }

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 10
                        rightMargin: 6
                        topMargin: 6
                        bottomMargin: 6
                    }
                    spacing: 6

                    Row {
                        spacing: 10
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: root.colorForTopic(topic)
                        }
                        Label {
                            text: topic
                            color: "#E0E0E0"
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }
                        Label {
                            text: time
                            color: "#A0E7FF"
                            font.pixelSize: 12
                        }
                    }

                    Text {
                        id: payloadText
                        text: payload
                        color: root.colorForTopic(topic)
                        font.family: "monospace"
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        height: 1
                        width: parent.width
                        color: "#2A3A98"
                    }
                }
            }
        }
    }

    // Nhận tất cả topic từ mqttClient, chỉ giữ maxLogs gần nhất
    Connections {
        target: mqttClient
        function onMessageReceived(topic, payload) {
            const ts = new Date().toLocaleTimeString();
            let body;

            // Rút gọn log cho QR-code: chỉ ghi status + độ dài base64
            if (topic.endsWith("/qr-code")) {
                const len = (payload && payload.qr_code) ? payload.qr_code.length : 0;
                const st = (payload && payload.status !== undefined) ? payload.status : "n/a";
                body = JSON.stringify({
                    status: st,
                    qr_code_len: len
                });
            } else {
                try {
                    body = JSON.stringify(payload, null, 2);
                } catch (e) {
                    body = String(payload);
                }
            }

            logModel.append({
                time: ts,
                topic: topic,
                payload: body
            });

            // cắt còn tối đa maxLogs
            if (logModel.count > root.maxLogs) {
                logModel.remove(0, logModel.count - root.maxLogs);
            }

            // tự cuộn xuống cuối
            logView.currentIndex = logModel.count - 1;
            logView.positionViewAtIndex(logModel.count - 1, ListView.End);
        }
    }
}
