import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    width: 1000
    height: 580
    title: "Help"

    Rectangle {
        width: 1000
        height: 580
        color: "#f4f4f4"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            Label {
                text: "Hướng Dẫn Sử Dụng Ứng Dụng"
                font.pixelSize: 36
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    spacing: 20
                    width: parent.width - 20

                    Label {
                        text: "📌 Giới thiệu"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Label {
                        text: "Ứng dụng này cho phép bạn quản lý các hộp chứa hàng, kiểm tra tình trạng pin, và quét mã QR để nhận hoặc gửi hàng."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                    }

                    Label {
                        text: "🛠 Cách sử dụng"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Label {
                        text: "1. Mở ứng dụng.\n"
                              + "2. Chọn chức năng mong muốn từ menu chính.\n"
                              + "3. Quét mã QR khi được yêu cầu.\n"
                              + "4. Kiểm tra trạng thái hộp và nhận thông báo."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                    }

                    Label {
                        text: "💡 Mẹo sử dụng"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Label {
                        text: "- Giữ kết nối mạng LAN để dữ liệu luôn được cập nhật.\n"
                              + "- Sạc pin khi dưới 20%.\n"
                              + "- Kiểm tra bản cập nhật ứng dụng thường xuyên."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                    }

                    Label {
                        text: "📞 Hỗ trợ"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Label {
                        text: "Email: support@teamdui.com\nSĐT: 0123 456 789"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                    }
                }
            }
        }
    }
}
