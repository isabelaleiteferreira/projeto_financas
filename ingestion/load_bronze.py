"""Ingestão das respostas da Pluggy na camada bronze."""

import os
from datetime import date, timedelta

import httpx
from db import conectar
from psycopg.types.json import Jsonb

BASE_URL = "https://api.pluggy.ai"


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


def salvar_bruto(conn, endpoint: str, payload: dict) -> None:
    """Grava uma resposta da API na bronze, sem alterações."""
    conn.execute(
        "INSERT INTO bronze.pluggy_raw (endpoint, payload) VALUES (%s, %s)",
        (endpoint, Jsonb(payload)),
    )


if __name__ == "__main__":
    api_key = autenticar()
    desde = (date.today() - timedelta(days=365)).isoformat()

    contas = httpx.get(
        f"{BASE_URL}/accounts",
        params={"itemId": os.environ["PLUGGY_ITEM_ID"]},
        headers={"X-API-KEY": api_key},
    )
    contas.raise_for_status()

    with conectar() as conn:
        salvar_bruto(conn, "accounts", contas.json())
        print("contas gravadas:", len(contas.json()["results"]))

        for conta in contas.json()["results"]:
            paginas = buscar_paginas_transacoes(api_key, conta["id"], desde)
            for pagina in paginas:
                salvar_bruto(conn, "transactions", pagina)
            total = sum(len(p["results"]) for p in paginas)
            print(conta["subtype"], "->", len(paginas), "páginas,", total, "transações")
