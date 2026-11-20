--- 0001: schemas do medalhão e de apoio

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA bronze IS 'Dados brutos da Pluggy, sem alteração';
COMMENT ON SCHEMA silver IS 'Dados tipados e deduplicados, criados pelo dbt';
COMMENT ON SCHEMA gold IS 'Métricas e visões para o app, criadas pelo dbt';
COMMENT ON SCHEMA app IS 'Dados digitados pelo usuário: metas, salários e premissas';
COMMENT ON SCHEMA audit IS 'Registro das execuções do pipeline';