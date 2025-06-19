import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Window {
    id: mainwindow
    signal showQRCode(string data)
    width: 1000
    height: 580
    opacity: 1
    visible: true
    color: "#00000000"
    title: qsTr("Couse")
    function openQRWindow(boxId) {
        var qmlFile = boxManager.getQRPage(boxId)
        var component = Qt.createComponent(qmlFile)
        if (component.status === Component.Ready) {
            var win = component.createObject()
            if (win) win.show()
        } else {
            console.error("Không thể tải cửa sổ từ:", qmlFile)
        }
    }

    Rectangle {
        id: bg
        color: "#152063"
        border.color: "#190249"
        border.width: 1
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 10
        anchors.bottomMargin: 10

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
                    text: qsTr("Admin")
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
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
                        text: qsTr("Hello World!")
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
                        Timer {
                            id: batteryTimer
                            interval: 5000 // 5 giây, bạn có thể giảm nếu muốn cập nhật nhanh hơn
                            running: true
                            repeat: true
                            onTriggered: {
                                boxManager.updateBatteryLevel()
                                let level = boxManager.getBatteryLevel()
                                pinbar.value = level
                                pintext.text = level + "%"

                                if (level > 60) {
                                    pinbar.dynamicColor = "#90ee90"
                                } else if (level >= 30) {
                                    pinbar.dynamicColor = "ffa500"
                                } else {
                                    pinbar.dynamicColor = "ff4500"
                                }
                            }
                        }

                        // Đảm bảo pinbar cập nhật đúng giá trị ban đầu
                        Component.onCompleted: {
                            boxManager.updateBatteryLevel()
                            pinbar.value = boxManager.getBatteryLevel()

                        }


                        ProgressBar {
                            id: pinbar
                            value: 50
                            anchors.left: image3.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 0
                            anchors.rightMargin: 60
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            to: 100
                            property color barColor: "#90ee90" // màu mặc định

                            contentItem: Rectangle {
                                width: pinbar.visualPosition * pinbar.width
                                height: pinbar.height
                                color: pinbar.barColor
                            }

                            background: Rectangle {
                                color: "#1e1e1e"
                                radius: 2
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
                        text: qsTr("FPT Delivery Car DUI")
                        anchors.left: image.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 5
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
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
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
                        border.color: "#4360f1"
                        border.width: 3
                        anchors.left: parent.left
                        anchors.right: box2.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: -2
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0

                        Image {
                            id: image1
                            x: 178
                            y: 69
                            width: 100
                            height: 100
                            source: "../images/svg_images/box_add_100dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                            fillMode: Image.PreserveAspectFit
                        }

                        Button {
                            id: button1
                            anchors.fill: parent
                            background: null
                            onClicked: {
                                openQRWindow("box1")
                            }

                        }
                    }

                    Rectangle {
                        id: box2
                        color: "#152063"
                        radius: 0
                        border.color: "#4360f1"
                        border.width: 3
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 453
                        anchors.rightMargin: 0
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0

                        Image {
                            id: image2
                            x: 178
                            y: 69
                            width: 100
                            height: 100
                            source: "../images/svg_images/add_box_96dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.svg"
                            fillMode: Image.PreserveAspectFit
                        }

                        Button {
                            id: button2
                            anchors.fill: parent
                            background: null
                            onClicked: {
                                openQRWindow("box2")
                            }
                        }
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
                        anchors.rightMargin: 500
                        source: "speedometer.qml"    // Thay bằng đường dẫn đúng tới file speedometer của bạn

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
                                    id: label2
                                    color: "#ffffff"
                                    text: qsTr("Available:")
                                }

                                Label {
                                    id: label5
                                    color: "#fffdfd"
                                    text: qsTr("Yes or Not")
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
                                    id: label4
                                    color: "#ffffff"
                                    text: qsTr("Box1: ")
                                }

                                Label {
                                    id: label6
                                    color: "#ffffff"
                                    text: qsTr("Box2:")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
