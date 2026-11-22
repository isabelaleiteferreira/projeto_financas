import os

import psycopg
from dotenv import load_dotenv

load_dotenv()


def conectar() -> psycopg.Connection:
    ref = os.environ["DB_USER"].split(".")[1]
    return psycopg.connect(
        host=os.environ["DB_HOST"],
        port=5432,
        dbname="postgres",
        user=f"airflow_ingest.{ref}",
        password=os.environ["AIRFLOW_DB_PASSWORD"],
    )


if __name__ == "__main__":
    with conectar() as conn:
        print(
            conn.execute(
                "SELECT current_user, count(*) FROM bronze.pluggy_raw"
            ).fetchone()
        )
