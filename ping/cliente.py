import requests
import time
from datetime import datetime

URL = "http://localhost:8080/health"

RETRY_DELAY = 2

while True:

    try:

        print(f"[{datetime.now()}] Enviando Healtcheck")

        response = requests.get(
            URL,
            timeout=5
        )

        print(
            f"[{datetime.now()}] "
            f"Status={response.status_code} "
            f"Response={response.text}"
        )

        # espera normal
        time.sleep(1)

    except requests.exceptions.ConnectionError:

        print(
            f"[{datetime.now()}] "
            f"Servidor abajo. Reintentando..."
        )

        time.sleep(RETRY_DELAY)

    except requests.exceptions.Timeout:

        print(
            f"[{datetime.now()}] "
            f"Tiempo agotado esperando response. Reintentando..."
        )

        time.sleep(RETRY_DELAY)

    except Exception as e:

        print(
            f"[{datetime.now()}] "
            f"Error inesperado: {e}"
        )

        time.sleep(RETRY_DELAY)