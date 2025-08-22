# mqtt_pyside.py
# pip install paho-mqtt
from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Dict, Any
import json
import paho.mqtt.client as mqtt
from PySide6 import QtCore


@dataclass
class MqttConfig:
    host: str = "192.168.0.107"
    port: int = 1883
    keepalive: int = 30
    username: Optional[str] = None
    password: Optional[str] = None
    robotCode: str = "ROBOT-001"
    containers: tuple[str, ...] = ("R-001_C-1", "R-001_C-2")


class MqttClient(QtCore.QObject):
    # ---- Signals ----
    connectedChanged = QtCore.Signal(bool)
    errorOccurred = QtCore.Signal(str)

    # Command feedback (server -> robot)
    qrCodeSenderStatus = QtCore.Signal(int)     # robot/<id>/command/qr-code/sender
    qrCodeReceiverStatus = QtCore.Signal(int)   # robot/<id>/command/qr-code/receiver
    forceMoveCommand = QtCore.Signal(str)       # end_point
    containerLoadCommand = QtCore.Signal(str, str)   # containerCode, tripId
    containerPickupCommand = QtCore.Signal(str, str) # containerCode, tripId
    tripMoveCommand = QtCore.Signal(str, str, str)   # tripId, start_point, end_point

    # Optional: raw message hook
    messageReceived = QtCore.Signal(str, dict)

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

    # ---------- Lifecycle ----------
    def connect(self):
        try:
            self._client.connect(self.cfg.host, self.cfg.port, self.cfg.keepalive)
            self._client.loop_start()
        except Exception as e:
            self.errorOccurred.emit(f"MQTT connect failed: {e}")

    def disconnect(self):
        try:
            self._client.loop_stop()
            self._client.disconnect()
        except Exception as e:
            self.errorOccurred.emit(f"MQTT disconnect failed: {e}")

    # ---------- Subscriptions ----------
    def _subscribe_all(self):
        # Fixed topics
        self._client.subscribe([
            (f"robot/{self.cfg.robotCode}/command/qr-code/sender", 1),
            (f"robot/{self.cfg.robotCode}/command/qr-code/receiver", 1),
            (f"robot/{self.cfg.robotCode}/command/force_move", 1),
            (f"robot/{self.cfg.robotCode}/command/trip/+/move", 1),
        ])
        # Per-container
        for c in self.cfg.containers:
            self._client.subscribe([
                (f"robot/{self.cfg.robotCode}/container/{c}/command/trip/+/load", 1),
                (f"robot/{self.cfg.robotCode}/container/{c}/command/trip/+/pickup", 1),
            ])

    # ---------- Publish helpers ----------
    def publish_location(self, roomCode: str, qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/location"
        self._publish_json(topic, {"roomCode": roomCode}, qos, retain)

    def publish_battery(self, battery: float, qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/battery"
        self._publish_json(topic, {"battery": float(battery)}, qos, retain)

    def publish_robot_status(self, status: str, qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/status"
        self._publish_json(topic, {"status": status}, qos, retain)

    def publish_container_status(self, containerCode: str, status: str, isClosed: bool,
                                 qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/container/{containerCode}/status"
        self._publish_json(topic, {"status": status, "isClosed": "true" if isClosed else "false"}, qos, retain)

    def publish_trip_progress(self, containerCode: str, tripId: str,
                              progress: float, start_point: str, end_point: str,
                              qos: int = 0, retain: bool = False):
        topic = f"robot/{self.cfg.robotCode}/trip/{tripId}"
        self._publish_json(topic, {
            "progress": float(progress),
            "start_point": start_point,
            "end_point": end_point
        }, qos, retain)

    def _publish_json(self, topic: str, payload: Dict[str, Any], qos: int, retain: bool):
        try:
            self._client.publish(topic, json.dumps(payload, ensure_ascii=False), qos=qos, retain=retain)
        except Exception as e:
            self.errorOccurred.emit(f"Publish failed {topic}: {e}")

    # ---------- Callbacks ----------
    def _on_connect(self, client, userdata, flags, rc):
        ok = (rc == 0)
        self._is_connected = ok
        self.connectedChanged.emit(ok)
        if ok:
            self._subscribe_all()
        else:
            self.errorOccurred.emit(f"MQTT connect rc={rc}")

    def _on_disconnect(self, client, userdata, rc):
        self._is_connected = False
        self.connectedChanged.emit(False)

    def _on_message(self, client, userdata, msg: mqtt.MQTTMessage):
        # parse JSON
        try:
            payload = json.loads(msg.payload.decode("utf-8")) if msg.payload else {}
            if not isinstance(payload, dict):
                payload = {}
        except Exception:
            payload = {}

        topic = msg.topic or ""
        self.messageReceived.emit(topic, payload)

        parts = topic.split("/")
        if len(parts) < 3 or parts[0] != "robot" or parts[1] != self.cfg.robotCode:
            return

        # robot/<id>/command/qr-code/sender|receiver
        if parts[2] == "command":
            if len(parts) >= 5 and parts[3] == "qr-code":
                if parts[4] == "sender":
                    self.qrCodeSenderStatus.emit(int(payload.get("status", -1)))
                    return
                if parts[4] == "receiver":
                    self.qrCodeReceiverStatus.emit(int(payload.get("status", -1)))
                    return
            # force_move
            if len(parts) >= 4 and parts[3] == "force_move":
                self.forceMoveCommand.emit(str(payload.get("end_point", "")))
                return
            # trip/<tripId>/move
            if len(parts) >= 6 and parts[3] == "trip" and parts[5] == "move":
                trip_id = parts[4]
                sp = str(payload.get("start_point", ""))
                ep = str(payload.get("end_point", ""))
                self.tripMoveCommand.emit(trip_id, sp, ep)
                return

        # robot/<id>/container/<containerCode>/command/trip/<tripId>/(load|pickup)
        if parts[2] == "container":
            if len(parts) >= 8 and parts[4] == "command" and parts[5] == "trip":
                container_code = parts[3]
                trip_id = parts[6]
                action = parts[7]
                if action == "load":
                    self.containerLoadCommand.emit(container_code, trip_id)
                elif action == "pickup":
                    self.containerPickupCommand.emit(container_code, trip_id)
