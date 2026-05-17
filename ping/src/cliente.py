import requests

def enviar_healthcheck(url):
    response = requests.get(url, timeout=5)
    return response.status_code, response.text