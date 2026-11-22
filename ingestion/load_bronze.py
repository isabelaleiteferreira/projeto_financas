"""Carga: lê os JSON do Storage e grava na bronze os arquivos ainda não carregados."""

from psycopg.types.json import Jsonb

from db import conectar
from storage import cliente, ler_json, listar

ENDPOINTS = ["accounts", "categories", "transactions"]


def main() -> None:
    s3 = cliente()
    with conectar() as conn:
        carregados = {
            linha[0]
            for linha in conn.execute(
                "SELECT arquivo FROM bronze.pluggy_raw WHERE arquivo IS NOT NULL"
            )
        }
        for endpoint in ENDPOINTS:
            arquivos = sorted(c for c in listar(s3, f"{endpoint}/") if c.endswith(".json"))
            novos = [c for c in arquivos if c not in carregados]
            for caminho in novos:
                conn.execute(
                    "INSERT INTO bronze.pluggy_raw (endpoint, arquivo, payload)"
                    " VALUES (%s, %s, %s) ON CONFLICT (arquivo) DO NOTHING",
                    (endpoint, caminho, Jsonb(ler_json(s3, caminho))),
                )
            print(endpoint, "->", len(novos), "arquivos novos carregados")


if __name__ == "__main__":
    main()
