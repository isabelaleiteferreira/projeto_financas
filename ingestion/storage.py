"""Acesso ao Supabase Storage pela API compatível com S3."""

import json
import os

import boto3
from botocore.config import Config
from dotenv import load_dotenv

load_dotenv()

BUCKET = "pluggy-raw"


def cliente():
    """Cria o cliente S3 apontando para o Storage do projeto."""
    ref = os.environ["DB_USER"].split(".")[1]
    return boto3.client(
        "s3",
        endpoint_url=f"https://{ref}.storage.supabase.co/storage/v1/s3",
        region_name=os.environ["STORAGE_REGION"],
        aws_access_key_id=os.environ["STORAGE_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["STORAGE_SECRET_ACCESS_KEY"],
        config=Config(s3={"addressing_style": "path"}),
    )


def enviar_json(s3, caminho: str, dados: dict) -> None:
    """Grava um objeto JSON no bucket."""
    s3.put_object(
        Bucket=BUCKET,
        Key=caminho,
        Body=json.dumps(dados, ensure_ascii=False).encode(),
        ContentType="application/json",
    )


def listar(s3, prefixo: str) -> list[str]:
    """Lista os caminhos de todos os arquivos sob o prefixo."""
    caminhos = []
    for pagina in s3.get_paginator("list_objects_v2").paginate(Bucket=BUCKET, Prefix=prefixo):
        caminhos += [obj["Key"] for obj in pagina.get("Contents", [])]
    return caminhos


def ler_json(s3, caminho: str) -> dict:
    """Lê um arquivo JSON do bucket."""
    return json.loads(s3.get_object(Bucket=BUCKET, Key=caminho)["Body"].read())
