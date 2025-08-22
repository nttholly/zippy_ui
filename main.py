from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal, QTimer
import sys
import psutil
import base64
import io
from PIL import Image
from mqtt_client import MqttClient, MqttConfig
from http_client import HttpClient

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
        self.loader = None
        self.updateBatteryLevel()
        self.http = HttpClient(base_url="http://192.168.0.107:8080", timeout=10.0)

    @Slot(str, result=str)
    def getQRPage(self, box_id):
        return "pages/QRdynamic.qml"

    @Slot(str, result=str)
    def getQRImage(self, box_id):
        """
        Empty box: return QR code (from API).
        Occupied box: emit alert and return a warning image.
        """
        state = self.box_states.get(box_id, False)

        if state:
            self.boxAlert.emit(box_id, "Box is occupied")
            return self._solid_color_png_data_url((255, 100, 100))  # red

        try:
            qr_b64 = self.http.fetch_qr_base64(path="/")  # adjust API path if needed
            if qr_b64:
                print("[DEBUG] QR code fetched successfully.")
                return f"data:image/png;base64,{qr_b64}"
            else:
                print("[WARN] QR not found in JSON, returning gray placeholder.")
                return self._solid_color_png_data_url((220, 220, 220))
        except requests.exceptions.ConnectionError:
            print("[ERROR] Cannot connect to API. Returning yellow warning placeholder.")
            return self._solid_color_png_data_url((255, 255, 102))
        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")
            return self._solid_color_png_data_url((220, 220, 220))

    def _solid_color_png_data_url(self, rgb):
        img = Image.new("RGB", (200, 200), color=rgb)
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        import base64
        return f"data:image/png;base64,{base64.b64encode(buf.getvalue()).decode('utf-8')}"

    @Slot()
    def updateBatteryLevel(self):
        battery = psutil.sensors_battery()
        if battery:
            self._batteryLevel = battery.percent
            self.batteryLevelChanged.emit()

    @Slot(result=int)
    def getBatteryLevel(self):
        return self._batteryLevel

    # About Us
    @Slot()
    def openAboutUs(self):
        if self.loader:
            self.loader.setProperty("source", "pages/Aboutus.qml")

    # Help
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
                print("Không kết nối được signal robotClicked:", e)

    QTimer.singleShot(100, connect_robot_signal)

    try:
        window.userInteracted.connect(reset_idle_timer)
    except Exception as e:
        print("Không thể kết nối signal userInteracted:", e)

    sys.exit(app.exec())
