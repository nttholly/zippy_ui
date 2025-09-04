import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 400
    height: 300
    color: "#0012192a"

    property string speechText: "Xin chào!"

    // === Thêm: dãy label hiển thị tuần tự ===
    property var labelSequence: ["Hello I'm Zippy", "Bạn yêu nhớ đóng\n nắp thùng hàng nhé <3", "Hmm...", "Bạn xinh đẹp đi\nđâu thế!", "Xem đây!", "Hehe ta tới đây!", "Đường này đây!\nPhải không nhỉ?"]
    property int labelIndex: 0
    function showNextLabel() {
        if (labelSequence.length === 0)
            return;
        warningText.text = labelSequence[labelIndex % labelSequence.length];
        labelIndex = (labelIndex + 1) % labelSequence.length;
    }

    // === Thêm: Timer quay vòng & giữ cảnh báo ===
    Timer {
        id: rotateTimer
        interval: 2000      // 2 giây đổi câu
        running: true
        repeat: true
        onTriggered: showNextLabel()
    }

    Timer {
        id: warningHoldTimer
        interval: 5000      // Giữ cảnh báo 5 giây rồi tiếp tục quay vòng
        repeat: false
        onTriggered: rotateTimer.start()
    }

    Component.onCompleted: showNextLabel()

    // --- Mắt ---
    Item {
        id: eyes
        width: 280
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 65
        anchors.horizontalCenterOffset: 6
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: eyeLeft
            width: 90
            height: 110
            radius: 30
            color: "#4FC3F7"
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenterOffset: -27
            anchors.verticalCenter: parent.verticalCenter

            transform: Scale {
                id: scaleLeft
                yScale: 1.0
            }
        }

        Rectangle {
            id: eyeRight
            x: 183
            width: 90
            height: 110
            radius: 30
            color: "#4FC3F7"
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenterOffset: -22
            anchors.verticalCenter: parent.verticalCenter

            transform: Scale {
                id: scaleRight
                yScale: 1.0
            }
        }

        Timer {
            interval: 4000
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
                    duration: 80
                }
                PropertyAnimation {
                    target: scaleRight
                    property: "yScale"
                    to: 0.1
                    duration: 80
                }
            }
            PauseAnimation {
                duration: 50
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: scaleLeft
                    property: "yScale"
                    to: 1.0
                    duration: 80
                }
                PropertyAnimation {
                    target: scaleRight
                    property: "yScale"
                    to: 1.0
                    duration: 80
                }
            }
        }
    }

    // --- Miệng ---
    Canvas {
        id: mouth
        width: 74
        height: 81
        anchors.top: eyes.bottom
        anchors.topMargin: 6
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        property real mouthSize: 30
        y: 171

        Timer {
            interval: 300
            running: true
            repeat: true
            onTriggered: {
                mouth.mouthSize = (mouth.mouthSize === 30) ? 45 : 30;
                mouth.requestPaint();
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = "#4FC3F7";
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, mouth.mouthSize / 2, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    // --- Cảnh báo từ boxManager: dùng chung warningText ---
    Connections {
        target: boxManager
        function onBoxAlert(boxId, message) {
            rotateTimer.stop();
            warningText.text = message;
            warningHoldTimer.restart();
        }
    }

    // --- Văn bản ---
    Rectangle {
        id: warningBox
        width: warningText.implicitWidth + 20
        height: warningText.implicitHeight + 20
        radius: 12
        color: "#4FC3F7"        // nền thông báo
        border.color: "#ffffff"
        border.width: 2
        visible: warningText.text !== ""   // chỉ hiển thị khi có nội dung

        anchors.top: mouth.bottom
        anchors.topMargin: -31
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 124

        Text {
            id: warningText
            anchors.centerIn: parent
            color: "#ffffff"
            text: ""                    // sẽ được set bởi showNextLabel()
            font.pixelSize: 18
            wrapMode: Text.Wrap
        }
    }

    // --- Cảnh báo từ MQTT: tạm dừng quay vòng, giữ 5s ---
    Connections {
        target: mqttClient
        function onMessageReceived(topic, payload) {
            if (topic.endsWith("/warning")) {
                // payload = {title, message, time_stamp}
                rotateTimer.stop();
                warningText.text = "⚠️ " + payload.title + "\n" + payload.message;
                warningHoldTimer.restart();
            }
        }
    }
}
