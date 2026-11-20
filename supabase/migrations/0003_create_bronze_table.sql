--- 0003: tabela bronze com o payload bruto da Pluggy

CREATE TABLE IF NOT EXISTS bronze.pluggy_raw (
    id          bigint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    endpoint    text       NOT NULL,
    ingerido_em timestamptz NOT NULL DEFAULT now(),
    payload     jsonb       NOT NULL

);

COMMENT ON TABLE bronze.pluggy_raw IS 'Respostas brutas da API Pluggy, append-only';

-- RLS: só os usuários do pipeline acessam a bronze
ALTER TABLE bronze.pluggy_raw ENABLE ROW LEVEL SECURITY;

CREATE POLICY ingest_insere ON bronze.pluggy_raw
    FOR INSERT TO airflow_ingest WITH CHECK (true);

CREATE POLICY ingest_le ON bronze.pluggy_raw
    FOR SELECT TO airflow_ingest USING (true);

CREATE POLICY dbt_le ON bronze.pluggy_raw
    FOR SELECT TO dbt_transform USING (true);