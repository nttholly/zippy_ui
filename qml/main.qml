import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Window {
    id: mainwindow
    visibility: Window.FullScreen               // bật true fullscreen
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint  // không viền + luôn trên cùng                        // nền OPAQUE (tránh compositor coi là trong suốt)
    Component.onCompleted: showFullScreen()
    signal showQRCode(string data)
    width: 1024
    height: 600
    opacity: 1
    visible: true
    signal userInteracted // 👈 thêm dòng này
    color: "#00000000"
    title: qsTr("Couse")
    function openQRWindow(boxId) {
        var qmlFile = boxManager.getQRPage(boxId);
        var component = Qt.createComponent(qmlFile);
        if (component.status === Component.Ready) {
            var win = component.createObject();
            if (win)
                win.show();
        } else {
            console.error("Không thể tải cửa sổ từ:", qmlFile);
        }
    }

    Rectangle {
        id: bg
        color: "#152063"
        border.color: "#190249"
        border.width: 1
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        Rectangle {
            id: appcontainer
            color: "#000427fa"
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.topMargin: 1
            anchors.bottomMargin: 1

            Rectangle {
                id: topbar
                height: 60
                color: "#070f37"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: 0

                Button {
                    id: button
                    width: 70
                    height: 60
                    anchors.left: parent.left
                    anchors.top: parent.top
                    background: null

                    Image {
                        anchors.fill: parent
                        source: "../images/svg_images/settings_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                        fillMode: Image.PreserveAspectFit
                    }

                    onClicked: passwordDialog.open()
                }

                Dialog {
                    id: passwordDialog
                    title: "Zippy Access Restricted"
                    modal: true
                    standardButtons: Dialog.Ok | Dialog.Cancel
                    focus: true
                    width: 952
                    height: 538
                    x: 70
                    y: 70
                    background: Rectangle {
                        color: "#152063"        // màu nền
                        radius: 12              // bo góc
                        border.color: "#152063" // viền xanh
                        border.width: 2
                    }

                    property string correctPassword: "tungkhanhlap"

                    contentItem: Column {
                        spacing: 20
                        anchors.centerIn: parent    // 👉 thay vì anchors.fill
                        width: parent.width * 0.6   // chỉ cần width, không fill chiều cao


                        Label {
                            text: "Enter password:"
                            color: "white"
                        }

                        TextField {
                            id: passwordField
                            echoMode: TextInput.Password
                            placeholderText: "Password"
                            width: parent.width
                        }
                    }

                    onAccepted: {
                        if (passwordField.text === correctPassword) {
                            pageLoader.source = "pages/list.qml"
                        } else {
                            console.log("❌ Sai mật khẩu")
                        }
                        passwordField.text = ""  // reset
                    }

                    onRejected: {
                        passwordField.text = ""
                    }
                }


                Rectangle {
                    id: topbardescription
                    y: 27
                    height: 25
                    color: "#081148"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 70
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0

                    Label {
                        id: labeltopinfo
                        color: "#948a94"
                        text: qsTr("Smart Lab")
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: 300
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0
                        verticalAlignment: Text.AlignVCenter
                    }
                    Connections {
                        target: mqttClient
                        function onMessageReceived(topic, payload) {
                            // tách theo dấu "/"
                            var parts = topic.split("/")
                            if (parts.length > 1) {
                                var robotId = parts[1]   // "ROBOT-001"
                                labeltopinfo.text = "Robot ID: " + robotId
                            }
                        }
                    }


                    Rectangle {
                        id: pin
                        color: "#001c2a4a"
                        radius: 5
                        border.color: "#4360f1"
                        border.width: 0
                        anchors.left: labeltopinfo.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0

                        Image {
                            id: image3
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 0
                            anchors.rightMargin: 270
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            source: "../images/svg_images/bolt_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                            fillMode: Image.PreserveAspectFit
                        }

                        ProgressBar {
                            id: pinbar
                            anchors.left: image3.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 0
                            anchors.rightMargin: 47
                            to: 100
                            value: 50
                            property color barColor: "#90ee90"

                            background: Rectangle {
                                color: "#444"
                                radius: 2
                            }

                            contentItem: Rectangle {
                                width: pinbar.visualPosition * parent.width
                                height: parent.height
                                color: pinbar.barColor
                                radius: 2
                                border.width: 0
                            }
                        }

                        Label {
                            id: pintext
                            color: "#fcfcfc"
                            text: qsTr("%pin")
                            anchors.left: pinbar.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Connections {
                            target: mqttClient
                            function onMessageReceived(topic, payload) {
                                if (topic.endsWith("/battery")) {
                                    let level = payload.battery;
                                    pinbar.value = level;
                                    pintext.text = level + "%";

                                    if (level <= 20) {
                                        pinbar.barColor = "#ff4500";  // đỏ
                                    } else if (level < 60) {
                                        pinbar.barColor = "#ffa500";  // cam
                                    } else {
                                        pinbar.barColor = "#90ee90";  // xanh lá
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: titlebar
                    height: 35
                    color: "#00ffffff"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 70
                    anchors.rightMargin: 105
                    anchors.topMargin: 0

                    Image {
                        id: image
                        width: 28
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 5
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0
                        source: "../images/svg_images/electric_car_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        id: label
                        color: "#fdfffd"
                        text: qsTr("ZIPPY Delivery Car DUI")
                        anchors.left: image.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 5
                        anchors.rightMargin: 0
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 20
                    }
                }
            }

            Rectangle {
                id: content
                color: "#00ffffff"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topbar.bottom
                anchors.bottom: parent.bottom
                anchors.topMargin: 0

                Rectangle {
                    id: leftmenu
                    width: 70
                    color: "#070f37"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20   // khoảng cách giữa các button
                        anchors.margins: 20
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        // Home button
                        Button {
                            id: home
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: 60
                            background: null

                            Image {
                                anchors.fill: parent
                                source: "../images/svg_images/home_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                                fillMode: Image.PreserveAspectFit
                            }
                            onClicked: pageLoader.source = ""   // đóng mọi trang
                        }

                        // Help button
                        Button {
                            id: helpbutton
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: 60
                            background: null

                            Image {
                                anchors.fill: parent
                                source: "../images/svg_images/help_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48(1).svg"
                                fillMode: Image.PreserveAspectFit
                            }
                            onClicked: {
                                if (pageLoader.source === "pages/Help.qml") {
                                    pageLoader.source = "";
                                } else {
                                    pageLoader.source = "pages/Help.qml";
                                }
                            }
                        }

                        // About us button
                        Button {
                            id: aboutusbutton
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: 60
                            background: null

                            Image {
                                anchors.fill: parent
                                source: "../images/svg_images/groups_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                                fillMode: Image.PreserveAspectFit
                            }
                            onClicked: {
                                if (pageLoader.source === "pages/Aboutus.qml") {
                                    pageLoader.source = "";
                                } else {
                                    pageLoader.source = "pages/Aboutus.qml";
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: boxhang
                    y: 260
                    height: 238
                    color: "#121d5f"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 70
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: box1
                        color: "#152063"
                        radius: 0
                        border.color: "#081148"
                        border.width: 3
                        anchors.fill: parent

                        Image {
                            id: image1
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 178
                            anchors.rightMargin: 176
                            anchors.topMargin: 69
                            anchors.bottomMargin: 69
                            source: "../images/svg_images/box_add_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                            fillMode: Image.PreserveAspectFit
                        }

                        Button {
                            id: button1
                            anchors.fill: parent
                            background: null
                            onClicked: {
                                qrloader.source = "pages/QRdynamic.qml";
                                qrloader.item.boxId = "box1";
                                qrloader.visible = true;
                            }
                        }
                    }

                    Rectangle {
                        id: rectangle
                        color: "#00ffffff"
                        anchors.left: parent.left
                        anchors.right: box1.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0
                    }
                }

                Rectangle {
                    id: status
                    color: "#00ffffff"
                    anchors.left: leftmenu.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: boxhang.top
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    Loader {
                        id: speedometerLoader
                        visible: true
                        anchors.fill: parent
                        anchors.leftMargin: 0
                        anchors.rightMargin: 483
                        source: "smallface.qml"    // Thay bằng đường dẫn đúng tới file speedometer của bạn

                    }

                    Rectangle {
                        id: statuscolumn
                        color: "#00ffffff"
                        anchors.left: speedometerLoader.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0

                        ColumnLayout {
                            id: columnLayout
                            anchors.fill: parent

                            RowLayout {
                                id: rowLayout1
                                width: 100
                                height: 100

                                Image {
                                    id: image4
                                    width: 100
                                    height: 100
                                    source: "../images/svg_images/location_on_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                                    Layout.maximumHeight: 80
                                    Layout.maximumWidth: 80
                                    fillMode: Image.PreserveAspectFit
                                }
                                Label {
                                    id: locationlabel
                                    color: "#ffffff"
                                    text: qsTr("Location:")
                                    Layout.maximumWidth: 85
                                }

                                Label {
                                    id: location
                                    color: "#ffffff"
                                    text: qsTr("Here")
                                }
                                Connections {
                                    target: mqttClient
                                    function onMessageReceived(topic, payload) {
                                        // robot/{robot_id}/location  Payload: {"roomCode":"DE-105"}
                                        if (topic.endsWith("/location")) {
                                            if (payload && payload.roomCode) {
                                                location.text = "📍 " + payload.roomCode
                                            } else if (payload && payload.x !== undefined && payload.y !== undefined) {
                                                // fallback nếu bạn gửi toạ độ
                                                location.text = "📍 (" + Number(payload.x).toFixed(2) + ", " + Number(payload.y).toFixed(2) + ")"
                                            } else {
                                                // fallback cuối cùng để dễ debug
                                                location.text = "📍 " + JSON.stringify(payload)
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                id: rowLayout2
                                width: 100
                                height: 100

                                Image {
                                    id: image5
                                    width: 100
                                    height: 100
                                    source: "../images/svg_images/calendar_month_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                                    Layout.maximumHeight: 80
                                    Layout.maximumWidth: 80
                                    fillMode: Image.PreserveAspectFit
                                }

                                Label {
                                    id: availablelabel
                                    color: "#ffffff"
                                    text: qsTr("Available:")
                                    state: ""
                                }

                                Label {
                                    id: available
                                    color: "#fffdfd"
                                    text: qsTr("Yes or Not")
                                }
                                Connections {
                                    target: mqttClient
                                    function onMessageReceived(topic, payload) {
                                        if (topic.endsWith("/status") && payload.status) {
                                            let s = payload.status;           // "free" | "non-free"
                                            s = s.charAt(0).toUpperCase() + s.slice(1);
                                            available.text = s;
                                            available.color = (payload.status === "free") ? "green" : "red";
                                        }
                                    }
                                }



                            }

                            RowLayout {
                                id: rowLayout3
                                width: 100
                                height: 100

                                Image {
                                    id: image6
                                    width: 100
                                    height: 100
                                    source: "../images/svg_images/check_box_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                                    Layout.maximumHeight: 80
                                    Layout.maximumWidth: 80
                                    fillMode: Image.PreserveAspectFit
                                }

                                Label {
                                    id: boxlabel
                                    color: "#ffffff"
                                    text: qsTr("Box: ")
                                }
                                Connections {
                                    target: mqttClient
                                    function onMessageReceived(topic, payload) {
                                        if (topic.endsWith("/container")) {
                                            const statusText = (payload.status === "free") ? "Empty" : "Full";
                                            const closedText = (String(payload.isClosed).toLowerCase() === "true") ? "Closed" : "Opened";
                                            const w = (payload.weight !== undefined) ? Number(payload.weight).toFixed(2) + " g" : "n/a";
                                            boxlabel.text = `Box: ${statusText} | ${closedText} | ${w}`;
                                            boxlabel.color = (statusText === "Full") ? "red" : "green";
                                        }
                                    }
                                }

                            }
                        }
                    }
                }

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    anchors.leftMargin: 70
                }

            }
        }
    }

    Loader {
        id: qrloader
        anchors.fill: parent
        visible: false
        z: 9999
    }
    Connections {
        target: mqttClient
        function onMessageReceived(topic, payload) {
            if (!topic.endsWith("/qr-code")) return;

            var st = Number(payload.status); // 1 = HIỂN THỊ, 0 = TẮT

            if (st === 1) {
                // Nếu đã có item thì chỉ cập nhật, tránh reload tốn thời gian
                if (qrloader.item && qrloader.item.applyQrPayload) {
                    qrloader.item.applyQrPayload(payload);
                } else {
                    // Qt >= 5.10: setSource(url, props)
                    if (qrloader.setSource) {
                        qrloader.setSource("pages/QRdynamic.qml", { initialPayload: payload });
                    } else {
                        // Fallback Qt cũ
                        qrloader.source = "pages/QRdynamic.qml";
                        Qt.callLater(function(){
                            if (qrloader.item && qrloader.item.applyQrPayload)
                                qrloader.item.applyQrPayload(payload);
                        });
                    }
                }
                qrloader.visible = true;
                qrloader.active  = true;

            } else if (st === 0) {
                // Ẩn + giải phóng tài nguyên
                qrloader.visible = false;
                qrloader.active  = false;
                qrloader.source  = "";
            }
        }
    }

    Loader {
        id: robotface
        objectName: "pageLoader" // 👉 thêm dòng này
        visible: false
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        source: "pages/Robotface.qml"

        // Thay bằng đường dẫn đúng tới file speedometer của bạn
    }
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        z: 0

        onPressed: function (mouse) {
            mouse.accepted = false;
            mainwindow.userInteracted();
        }
        onReleased: function (mouse) {
            mouse.accepted = false;
        }
        onClicked: function (mouse) {
            mouse.accepted = false;
        }
    }
}
