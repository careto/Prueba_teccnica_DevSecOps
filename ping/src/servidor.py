from flask import Flask, jsonify, send_from_directory, request
from datetime import datetime
import threading
import os

app = Flask(__name__, static_folder="./frontend", static_url_path="")

class LogEntry:
    def __init__(self, method, path, response):
        self.time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.method = method
        self.path = path
        self.response = response

    def to_dict(self):
        return {
            "time": self.time,
            "method": self.method,
            "path": self.path,
            "response": self.response
        }

logs = []
lock = threading.Lock()

@app.route("/health", methods=["GET"])
def health():
    entry = LogEntry(
        method=request.method,
        path=request.path,
        response="Healthcheck OK"
    )

    with lock:
        logs.append(entry.to_dict())

    print(
        f"[{entry.time}] "
        f"{entry.method} "
        f"{entry.path} -> "
        f"{entry.response}"
    )

    return "PONG", 200

@app.route("/logs", methods=["GET"])
def get_logs():
    with lock:
        return jsonify(logs)

@app.route("/")
def serve_index():
    return send_from_directory("./frontend", "index.html")

@app.route("/<path:path>")
def serve_static(path):
    return send_from_directory("./frontend", path)

if __name__ == "__main__":
    print("Servidor arriba en http://localhost")

    app.run(
        host="0.0.0.0",
        port=80
    )