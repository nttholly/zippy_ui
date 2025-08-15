import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    width: 1000
    height: 580

    Rectangle {
        width: 1000
        height: 580
        color: "#f4f4f4"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            Label {
                text: "About us"
                font.pixelSize: 36
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Chúng tôi là một nhóm gồm 3 thành viên S"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 18
            }

            RowLayout {
                spacing: 80
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true

                // Thành viên 1
                ColumnLayout {
                    spacing: 15
                    Rectangle {
                        width: 200
                        height: 200
                        radius: width / 2
                        clip: true
                        color: "white"
                        Image {
                            anchors.fill: parent
                            source: "../../images/jepg_images/Lap.jpeg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    Label {
                        text: "NGUYEN THANH LAP"
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        text: "Hardware and firmware"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Thành viên 2
                ColumnLayout {
                    spacing: 15
                    Rectangle {
                        width: 200
                        height: 200
                        radius: width / 2
                        clip: true
                        color: "white"
                        Image {
                            anchors.fill: parent
                            source: "../../images/jepg_images/khanh.jpeg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    Label {
                        text: "NGUYEN CONG KHANH"
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        text: "Leader"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Thành viên 3
                ColumnLayout {
                    spacing: 15
                    Rectangle {
                        width: 200
                        height: 200
                        radius: width / 2
                        clip: true
                        color: "white"
                        Image {
                            anchors.fill: parent
                            source: "../../images/jepg_images/tung.jpeg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    Label {
                        text: "NGUYEN THANH TUNG"
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        text: "DUI Designer"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
