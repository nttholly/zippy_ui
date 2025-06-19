from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal
import sys
import psutil

class BoxManager(QObject):
    batteryLevelChanged = Signal()  # 🔋 Signal để thông báo QML khi % pin thay đổi

    def __init__(self):
        super().__init__()

        # Trạng thái từng hộp
        self.box_states = {
            "box1": False,  # Trống
            "box2": False,  # Có hàng
        }

        # Giá trị phần trăm pin ban đầu
        self._batteryLevel = 0
        self.updateBatteryLevel()

    # ⚙️ Hàm lấy trang QML QR tương ứng với trạng thái hộp
    @Slot(str, result=str)
    def getQRPage(self, box_id):
        state = self.box_states.get(box_id, False)
        return "pages/QRfull.qml" if state else "pages/QRempty.qml"

    # 🔋 Hàm cập nhật phần trăm pin
    @Slot()
    def updateBatteryLevel(self):
        battery = psutil.sensors_battery()
        if battery:
            self._batteryLevel = battery.percent
            self.batteryLevelChanged.emit()

    # 🔋 Hàm trả về phần trăm pin cho QML
    @Slot(result=int)
    def getBatteryLevel(self):
        return self._batteryLevel


if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    manager = BoxManager()
    engine.rootContext().setContextProperty("boxManager", manager)

    engine.load("qml/main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
