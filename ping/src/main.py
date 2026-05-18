from cliente import enviar_healthcheck
import time
from datetime import datetime
import os

#URL = "http://localhost/health"
URL = os.getenv('TARGET_URL')

while True:
    try:
        print(f"[{datetime.now()}] Enviando Healtcheck")

        status, text = enviar_healthcheck(URL)

        print(f"[{datetime.now()}] Status={status} Response={text}")

        time.sleep(1)

    except Exception as e:
        print(f"Error: {e}")
        time.sleep(2)