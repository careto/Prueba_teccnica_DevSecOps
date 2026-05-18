from flask import Flask, jsonify, send_from_directory, request
from cliente import enviar_healthcheck

from datetime import datetime
import threading
import time
import os

#################################################
# Flask App
#################################################

app = Flask(__name__, static_folder="./frontend", static_url_path="")

logs = []
lock = threading.Lock()

#################################################
# Health Endpoint
#################################################

@app.route("/health", methods=["GET"])
def health():

    entry = {
        "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "method": request.method,
        "path": request.path,
        "response": "Healthcheck OK"
    }

    with lock:
        logs.append(entry)

    print(
        f"[{entry['time']}] "
        f"{entry['method']} "
        f"{entry['path']} -> "
        f"{entry['response']}"
    )

    return "PONG", 200

#################################################
# Logs Endpoint
#################################################

@app.route("/logs", methods=["GET"])
def get_logs():
    with lock:
        return jsonify(logs)

#################################################
# Frontend
#################################################

@app.route("/")
def serve_index():
    return send_from_directory("./frontend", "index.html")

@app.route("/<path:path>")
def serve_static(path):
    return send_from_directory("./frontend", path)

#################################################
# Background Healthcheck Client
#################################################

def healthcheck_loop():

    url = os.getenv("TARGET_URL")

    while True:
        try:
            print(f"[{datetime.now()}] Enviando Healthcheck")

            status, text = enviar_healthcheck(url)

            print(
                f"[{datetime.now()}] "
                f"Status={status} "
                f"Response={text}"
            )

            time.sleep(1)

        except Exception as e:
            print(f"Error: {e}")
            time.sleep(2)

#################################################
# Main
#################################################

if __name__ == "__main__":

    print("Servidor arriba en http://localhost")

    #################################################
    # Start background thread
    #################################################

    thread = threading.Thread(target=healthcheck_loop, daemon=True)
    thread.start()

    #################################################
    # Start Flask
    #################################################

    app.run(
        host="0.0.0.0",
        port=80
    )