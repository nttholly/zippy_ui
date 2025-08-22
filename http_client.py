# This Python file uses the following encoding: utf-8

# if __name__ == "__main__":
#     pass
from __future__ import annotations
from typing import Optional
import requests

class HttpClient:
    """Very small HTTP wrapper for QR code API."""
    def __init__(self, base_url: str, timeout: float = 10.0):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    def fetch_qr_base64(self, path: str = "/") -> Optional[str]:
        """
        Returns base64 string of QR if available, otherwise None.
        Expects JSON: {"data": {"qrCodeBase64": "..."}}
        """
        url = self.base_url + path
        resp = requests.get(url, timeout=self.timeout)
        if resp.status_code != 200:
            return None
        data = resp.json()
        return (data.get("data") or {}).get("qrCodeBase64")
