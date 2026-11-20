"""Verifica a conexão com a API da Pluggy listando as contas do item configurado."""

import os

import httpx
from dotenv import load_dotenv

BASE_URL = "https://api.pluggy.ai"

load_dotenv()

auth = httpx.post(
    f"{BASE_URL}/auth",
    json={
        "clientId": os.environ["PLUGGY_CLIENT_ID"],
        "clientSecret": os.environ["PLUGGY_CLIENT_SECRET"],
    },
)
auth.raise_for_status()
api_key = auth.json()["apiKey"]

contas = httpx.get(
    f"{BASE_URL}/accounts",
    params={"itemId": os.environ["PLUGGY_ITEM_ID"]},
    headers={"X-API-KEY": api_key},
)
contas.raise_for_status()

# Exibe apenas identificadores e tipos, sem saldos ou dados pessoais
for conta in contas.json()["results"]:
    print(conta["id"], conta["type"], conta["subtype"])
