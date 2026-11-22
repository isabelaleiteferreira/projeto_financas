"""Extração: busca contas e transações na Pluggy e grava o JSON bruto no Storage."""

import os
from datetime import UTC, date, datetime, timedelta

import httpx

from storage import cliente, enviar_json

BASE_URL = "https://api.pluggy.ai"
DIAS_HISTORICO = 365


def autenticar() -> str:
    """Retorna a apiKey da Pluggy."""
    resposta = httpx.post(
        f"{BASE_URL}/auth",
        json={
            "clientId": os.environ["PLUGGY_CLIENT_ID"],
            "clientSecret": os.environ["PLUGGY_CLIENT_SECRET"],
        },
    )
    resposta.raise_for_status()
    return resposta.json()["apiKey"]


def buscar_paginas_transacoes(api_key: str, conta_id: str, desde: str) -> list[dict]:
    """Percorre o cursor de /v2/transactions e retorna todas as páginas."""
    paginas = []
    url = f"{BASE_URL}/v2/transactions"
    params = {"accountId": conta_id, "dateFrom": desde}
    while True:
        resposta = httpx.get(url, params=params, headers={"X-API-KEY": api_key})
        resposta.raise_for_status()
        pagina = resposta.json()
        paginas.append(pagina)
        if not pagina.get("next"):
            return paginas
        # next já traz a query string completa da próxima página
        url = f"{BASE_URL}/v2/transactions{pagina['next']}"
        params = None


def main() -> None:
    api_key = autenticar()
    s3 = cliente()
    agora = datetime.now(UTC)
    # particionado por data de extração: <endpoint>/dt=AAAA-MM-DD/<horário>...
    pasta = f"dt={agora:%Y-%m-%d}"
    carimbo = f"{agora:%H%M%S}"
    desde = (date.today() - timedelta(days=DIAS_HISTORICO)).isoformat()

    contas = httpx.get(
        f"{BASE_URL}/accounts",
        params={"itemId": os.environ["PLUGGY_ITEM_ID"]},
        headers={"X-API-KEY": api_key},
    )
    contas.raise_for_status()
    enviar_json(s3, f"accounts/{pasta}/{carimbo}.json", contas.json())
    print("contas:", len(contas.json()["results"]))

    for conta in contas.json()["results"]:
        paginas = buscar_paginas_transacoes(api_key, conta["id"], desde)
        for n, pagina in enumerate(paginas, start=1):
            caminho = f"transactions/{pasta}/{carimbo}_{conta['id']}_{n:03d}.json"
            enviar_json(s3, caminho, pagina)
        total = sum(len(p["results"]) for p in paginas)
        print(conta["subtype"], "->", len(paginas), "arquivos,", total, "transações")


if __name__ == "__main__":
    main()
