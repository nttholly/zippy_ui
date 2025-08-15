from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal, QTimer
import sys
import psutil
import base64
import requests
import io
from PIL import Image


class BoxManager(QObject):
    batteryLevelChanged = Signal()
    boxAlert = Signal(str, str)  # box_id, message

    def __init__(self):
        super().__init__()
        self.box_states = {
            "box1": False,
            "box2": False,
        }
        self._batteryLevel = 0
        self.loader = None  # sẽ được gán từ main.py
        self.updateBatteryLevel()

    @Slot(str, result=str)
    def getQRPage(self, box_id):
        return "pages/QRdynamic.qml"

    @Slot(str, result=str)
    def getQRImage(self, box_id):
        """
        Box trống: trả QR code từ API
        Box đầy: gửi cảnh báo tới smallface và trả ảnh cảnh báo
        """
        state = self.box_states.get(box_id, False)

        if state:  # Box đầy
            self.boxAlert.emit(box_id, "Đã có hàng")
            img = Image.new("RGB", (200, 200), color=(255, 100, 100))
            buf = io.BytesIO()
            img.save(buf, format="PNG")
            img_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")
            return f"data:image/png;base64,{img_b64}"

        # Box trống → Lấy QR code từ API
        order_code = "O-122864"
        api_url = f"http://192.168.0.107:8080"

        try:
            print(f"🔍 [DEBUG] Đang gọi API: {api_url}")
            response = requests.get(api_url, timeout=10)
            print(f"🔍 [DEBUG] API status: {response.status_code}")

            if response.status_code == 200:
                response_data = response.json()
                if 'data' in response_data and 'qrCodeBase64' in response_data['data']:
                    qr_base64 = response_data['data']['qrCodeBase64']
                    print("✅ [DEBUG] Lấy QR code thành công.")
                    return f"data:image/png;base64,{qr_base64}"
                else:
                    print("⚠️ [DEBUG] API trả về JSON nhưng không có key 'qrCodeBase64'.")
            else:
                print(f"⚠️ [DEBUG] API trả về status code {response.status_code}")

        except requests.exceptions.ConnectionError:
            print(f"❌ [DEBUG] Không thể kết nối API tại {api_url}. Kiểm tra IP/Port hoặc mạng LAN.")
            # Ảnh vàng cảnh báo kết nối
            img = Image.new("RGB", (200, 200), color=(255, 255, 102))
            buf = io.BytesIO()
            img.save(buf, format="PNG")
            img_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")
            return f"data:image/png;base64,{img_b64}"

        except Exception as e:
            print(f"❌ [DEBUG] Lỗi không xác định khi gọi API: {e}")

        # Nếu lỗi khác → trả ảnh xám
        img = Image.new("RGB", (200, 200), color=(220, 220, 220))
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        img_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")
        return f"data:image/png;base64,{img_b64}"

    @Slot()
    def updateBatteryLevel(self):
        battery = psutil.sensors_battery()
        if battery:
            self._batteryLevel = battery.percent
            self.batteryLevelChanged.emit()

    @Slot(result=int)
    def getBatteryLevel(self):
        return self._batteryLevel

    # ✅ Slot mở trang About Us
    @Slot()
    def openAboutUs(self):
        if self.loader:
            self.loader.setProperty("source", "pages/Aboutus.qml")

    # ✅ Slot mở trang Help
    @Slot()
    def openHelp(self):
        if self.loader:
            self.loader.setProperty("source", "pages/Help.qml")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    manager = BoxManager()
    engine.rootContext().setContextProperty("boxManager", manager)

    engine.load("qml/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)

    window = engine.rootObjects()[0]
    loader = window.findChild(QObject, "pageLoader")

    # Gán loader cho manager để có thể đổi trang từ Python
    manager.loader = loader

    idle_timer = QTimer()
    idle_timer.setInterval(30_000)
    idle_timer.setSingleShot(True)

    def show_robotface():
        loader.setProperty("source", "pages/Robotface.qml")
        QTimer.singleShot(100, connect_robot_signal)

    def reset_idle_timer():
        if loader.property("source") == "":
            idle_timer.start()

    idle_timer.timeout.connect(show_robotface)

    def switch_to_mainpage():
        loader.setProperty("source", "")
        idle_timer.start()

    def connect_robot_signal():
        robot_face = loader.property("item")
        if robot_face:
            try:
                robot_face.robotClicked.connect(switch_to_mainpage)
            except Exception as e:
                print("❌ Không kết nối được signal robotClicked:", e)

    QTimer.singleShot(100, connect_robot_signal)

    try:
        window.userInteracted.connect(reset_idle_timer)
    except Exception as e:
        print("⚠️ Không thể kết nối signal userInteracted:", e)

    sys.exit(app.exec())
