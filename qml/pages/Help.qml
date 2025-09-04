import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    width: 952
    height: 538

    Rectangle {
        width: 1000
        height: 580
        color: "#152063"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            Label {
                text: "Hướng Dẫn Sử Dụng Zippy"
                font.pixelSize: 36
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                color: "white"
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
                        color: "white"
                    }
                    Label {
                        text: "Zippy là một robot giao hàng được phát triển bởi 3 sinh viên chuyên ngành IoT của đại học FPT\n trong đồ án tốt nghiệp:\n Smart Solutions: IoT and Robotic to Enhance Delivery Service Efficiency \n Nguyễn Thành Lập, Nguyễn Thành Tùng, Nguyễn Công Khanh.\n"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                        color: "white"
                    }

                    Label {
                        text: "🛠 Cách sử dụng"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                    }
                    Label {
                        text: "1.Chọn bỉểu tượng box để đặt hàng và nhận hàng, Quét QR khi QR hiện lên.\n2. Kiểm tra trạng thái hộp và vị trí ở các status ở bên phải.\n3.Chú ý đọc các thông báo từ Zippy'face nhỏ.\n4.CHÚ Ý ĐÓNG NẮP HỘP KHI NHẬN HÀNG/GỬI HÀNG."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                        color: "white"
                    }

                    Label {
                        text: "💡 Mẹo sử dụng"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                    }
                    Label {
                        text: "- Giữ kết nối mạng LAN để dữ liệu luôn được cập nhật."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                        color: "white"
                    }

                    Label {
                        text: "📞 Hỗ trợ"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                    }
                    Label {
                        text: "Email: tungthhb@gmail.com\nSĐT: 0944971696"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                        color: "white"
                    }
                }
            }
        }
    }
}
