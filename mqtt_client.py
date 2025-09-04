# mqtt_client.py
# pip install paho-mqtt
from __future__ import annotations

import os, base64, glob, time, json
from dataclasses import dataclass
from typing import Optional, Dict, Any, List
import paho.mqtt.client as mqtt
from PySide6 import QtCore


@dataclass
class MqttConfig:
    # Ví dụ: broker nội bộ
    host: str = "192.168.0.191"
    port: int = 21213
    keepalive: int = 30
    username: Optional[str] = "admin"
    password: Optional[str] = "123@123"
    robotCode: str = "ROBOT001"


class MqttClient(QtCore.QObject):
    # ---- Signals ----
    connectedChanged = QtCore.Signal(bool)
    errorOccurred = QtCore.Signal(str)
    messageReceived = QtCore.Signal(str, dict)  # topic, payload

    def __init__(self, cfg: MqttConfig):
        super().__init__()
        self.cfg = cfg
        self._client = mqtt.Client(client_id=f"{cfg.robotCode}-client", clean_session=True)
        if cfg.username:
            self._client.username_pw_set(cfg.username, cfg.password)

        self._client.on_connect = self._on_connect
        self._client.on_disconnect = self._on_disconnect
        self._client.on_message = self._on_message
        self._is_connected = False

        # ---- Debug/health state ----
        self._subscribed_topics: List[str] = []
        self._topic_last_ts: Dict[str, float] = {}   # last received time per topic
        self._topic_count: Dict[str, int] = {}       # total messages per topic
        self._expected_periods: Dict[str, float] = {}  # topic -> expected period seconds

        # Health monitor timer (mặc định 10s)
        self._health_timer = QtCore.QTimer(self)
        self._health_timer.setInterval(10_000)
        self._health_timer.timeout.connect(self._dump_topic_health)
        self._health_timer.start()

    # ---------- Lifecycle ----------
    def connect(self):
        try:
            print(f"[MQTT][CONNECT] -> {self.cfg.host}:{self.cfg.port} as {self.cfg.robotCode}")
            self._client.connect(self.cfg.host, self.cfg.port, self.cfg.keepalive)
            self._client.loop_start()
        except Exception as e:
            self.errorOccurred.emit(f"MQTT connect failed: {e}")

    def disconnect(self):
        try:
            self._client.loop_stop()
            self._client.disconnect()
            print("[MQTT][DISCONNECT] Disconnected")
        except Exception as e:
            self.errorOccurred.emit(f"MQTT disconnect failed: {e}")

    # ---------- Subscriptions ----------
    def _subscribe_all(self):
        topics = [
            (f"robot/{self.cfg.robotCode}/trip/state", 1),
            (f"robot/{self.cfg.robotCode}/heartbeat", 1),
            (f"robot/{self.cfg.robotCode}/location", 1),
            (f"robot/{self.cfg.robotCode}/status", 1),
            (f"robot/{self.cfg.robotCode}/container", 1),
            (f"robot/{self.cfg.robotCode}/qr-code", 1),   # NEW: subscribe QR code
        ]
        for t, qos in topics:
            self._client.subscribe((t, qos))
            self._subscribed_topics.append(t)
            print(f"[MQTT][SUB] {t} (qos={qos})")

        # (Tùy chọn) đặt kỳ vọng chu kỳ cho các topic (giúp phát hiện STALE)
        self.set_expected_period("heartbeat", 5)
        self.set_expected_period("status", 30)
        self.set_expected_period("location", 30)
        self.set_expected_period("trip/state", 30)
        self.set_expected_period("container", 30)
        self.set_expected_period("qr-code", 60)  # NEW: QR có thể đổi không thường xuyên

    # ---------- Debug helpers ----------
    def set_expected_period(self, topic_suffix: str, period_seconds: float):
        """Đặt kỳ vọng chu kỳ cho một topic theo suffix, ví dụ 'heartbeat' hoặc 'trip/state'."""
        full_topic = f"robot/{self.cfg.robotCode}/{topic_suffix}"
        self._expected_periods[full_topic] = float(period_seconds)
        print(f"[MQTT][EXPECT] {full_topic} period≈{period_seconds}s")

    def set_health_interval(self, ms: int):
        """Đổi chu kỳ in health (mặc định 10s)."""
        self._health_timer.setInterval(int(ms))

    def _dump_topic_health(self):
        now = time.time()
        if not self._subscribed_topics:
            return
        print("=== [MQTT][HEALTH] Topic activity ===")
        for t in self._subscribed_topics:
            last = self._topic_last_ts.get(t)
            count = self._topic_count.get(t, 0)
            if last is None:
                age_str = "never"
            else:
                age = now - last
                age_str = f"{age:.1f}s ago"
            status = "OK"
            exp = self._expected_periods.get(t)
            if exp is not None:
                # Nếu chưa từng nhận hoặc quá 3 lần kỳ vọng -> STALE
                if (last is None) or ((now - last) > (3 * exp)):
                    status = "STALE"
            print(f" - {t} | last: {age_str} | count: {count} | {status}")
        print("=====================================")

    # ---------- Publish helpers ----------
    def publish_trip_state(self, trip_id: str, progress: float, status: int,
                           start_point: str, end_point: str,
                           qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/trip/state"
        data = {
            "trip_id": trip_id,
            "progress": float(progress),
            "status": int(status),
            "start_point": start_point,
            "end_point": end_point
        }
        print(f"[MQTT][PUB] {topic} {data}")
        self._publish_json(topic, data, qos, retain)

    def publish_heartbeat(self, isAlive: bool = True, qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/heartbeat"
        data = {"isAlive": bool(isAlive)}
        print(f"[MQTT][PUB] {topic} {data}")
        self._publish_json(topic, data, qos, retain)

    def publish_location(self, roomCode: str, qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/location"
        data = {"roomCode": roomCode}
        print(f"[MQTT][PUB] {topic} {data}")
        self._publish_json(topic, data, qos, retain)

    def publish_status(self, status: str, qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/status"
        data = {"status": status}
        print(f"[MQTT][PUB] {topic} {data}")
        self._publish_json(topic, data, qos, retain)

    def publish_container(self, status: str, isClosed, weight: float,
                          qos: int = 0, retain: bool = False):
        """isClosed có thể là bool hoặc 'true'/'false' string"""
        topic = f"robot/{self.cfg.robotCode}/container"
        # Chuẩn hóa isClosed thành chuỗi "true"/"false" theo spec
        if isinstance(isClosed, bool):
            isClosed_str = "true" if isClosed else "false"
        else:
            isClosed_str = str(isClosed).lower()
            isClosed_str = "true" if isClosed_str in ("true", "1", "yes") else "false"
        data = {"status": status, "isClosed": isClosed_str, "weight": float(weight)}
        print(f"[MQTT][PUB] {topic} {data}")
        self._publish_json(topic, data, qos, retain)

    def publish_qr_code(self, qr_base64: str, status: int, qos: int = 0, retain: bool = False):
        """Tùy chọn nếu muốn publish từ robot (ít dùng)"""
        topic = f"robot/{self.cfg.robotCode}/qr-code"
        data = {"qrCode": qr_base64, "status": int(status)}
        print(f"[MQTT][PUB] {topic} (len={len(qr_base64)}) status={status}")
        self._publish_json(topic, data, qos, retain)

    def _publish_json(self, topic: str, payload: Dict[str, Any], qos: int, retain: bool):
        try:
            self._client.publish(topic, json.dumps(payload, ensure_ascii=False), qos=qos, retain=retain)
        except Exception as e:
            self.errorOccurred.emit(f"Publish failed {topic}: {e}")

    # ---------- QR helpers ----------
    def _strip_data_url_prefix(self, s: str) -> str:
        """Loại bỏ tiền tố data:image/...;base64, nếu có."""
        if not s:
            return s
        s = s.strip()
        i = s.find("base64,")
        if s.lower().startswith("data:") and i != -1:
            return s[i + len("base64,"):]
        return s

    def _save_base64_png(self, b64: str) -> Optional[str]:
        """Giải mã base64 PNG -> file tạm; trả về đường dẫn file."""
        try:
            raw = base64.b64decode(b64)
        except Exception as e:
            print(f"[MQTT][QR] base64 decode error: {e}")
            return None

        tmpdir = QtCore.QStandardPaths.writableLocation(QtCore.QStandardPaths.TempLocation) or "/tmp"
        # Dùng timestamp để tránh cache; ví dụ: ROBOT001_qr_1693751234567.png
        filename = f"{self.cfg.robotCode}_qr_{int(time.time() * 1000)}.png"
        path = os.path.join(tmpdir, filename)
        try:
            with open(path, "wb") as f:
                f.write(raw)
            # dọn rác cũ (giữ lại 5 file gần nhất)
            self._cleanup_old_qr_files(tmpdir, f"{self.cfg.robotCode}_qr_")
            return path
        except Exception as e:
            print(f"[MQTT][QR] write file error: {e}")
            return None

    def _cleanup_old_qr_files(self, tmpdir: str, prefix: str, keep: int = 5):
        try:
            pattern = os.path.join(tmpdir, f"{prefix}*.png")
            files = [(p, os.path.getmtime(p)) for p in glob.glob(pattern)]
            files.sort(key=lambda x: x[1], reverse=True)
            for p, _ in files[keep:]:
                try:
                    os.remove(p)
                except Exception:
                    pass
        except Exception:
            pass

    # ---------- Callbacks ----------
    def _on_connect(self, client, userdata, flags, rc):
        ok = (rc == 0)
        print(f"[MQTT][CONNECT] rc={rc} -> {'OK' if ok else 'FAIL'}")
        self._is_connected = ok
        self.connectedChanged.emit(ok)
        if ok:
            self._subscribe_all()
        else:
            self.errorOccurred.emit(f"MQTT connect rc={rc}")

    def _on_disconnect(self, client, userdata, rc):
        self._is_connected = False
        print(f"[MQTT][DISCONNECT] rc={rc}")
        self.connectedChanged.emit(False)

    def _on_message(self, client, userdata, msg: mqtt.MQTTMessage):
        # Parse JSON payload
        try:
            payload = json.loads(msg.payload.decode("utf-8")) if msg.payload else {}
            if not isinstance(payload, dict):
                payload = {}
        except Exception:
            payload = {}

        topic = msg.topic or ""
        now = time.time()

        # Thống kê/flow
        prev = self._topic_last_ts.get(topic)
        self._topic_last_ts[topic] = now
        self._topic_count[topic] = self._topic_count.get(topic, 0) + 1

        # === QR-code: decode base64 & đính kèm đường dẫn file local ===
        if topic.endswith("/qr-code"):
            b64 = None
            if isinstance(payload, dict):
                b64 = payload.get("qrCode") or payload.get("qr_code")
            if isinstance(b64, str) and b64.strip():
                b64 = self._strip_data_url_prefix(b64)
                fn = self._save_base64_png(b64)
                if fn:
                    # gửi đường dẫn file cho QML
                    payload["_local_qr_file"] = fn
                    print(f"[MQTT][QR] wrote -> {fn}")

        print(f"[MQTT][MSG] {topic} -> {payload}")
        if prev is not None:
            dt = now - prev
            print(f"[MQTT][FLOW] {topic} count={self._topic_count[topic]} Δt={dt:.3f}s")
        else:
            print(f"[MQTT][FLOW] {topic} first message")

        # Emit cho QML/app
        self.messageReceived.emit(topic, payload)
