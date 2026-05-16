from ping.cliente import enviar_healthcheck
import requests

def test_enviar_healthcheck(monkeypatch):

    class FakeResponse:
        status_code = 200
        text = "OK"

    def fake_get(*args, **kwargs):
        return FakeResponse()

    monkeypatch.setattr(requests, "get", fake_get)

    status, text = enviar_healthcheck("http://prueba.com/health")

    assert status == 200
    assert text == "OK"