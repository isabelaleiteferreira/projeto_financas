-- 0002: usuários de banco com permissões mínimas


-- airflow_ingest: grava dados brutos e registros de execução
CREATE ROLE airflow_ingest LOGIN;
GRANT USAGE ON SCHEMA bronze, audit TO airflow_ingest;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA bronze, audit TO airflow_ingest;
ALTER DEFAULT PRIVILEGES IN SCHEMA bronze, audit GRANT SELECT, INSERT ON TABLES TO airflow_ingest;

-- dbt_transform: lê bronze e app, cria e recria silver e gold
CREATE ROLE dbt_transform LOGIN;
GRANT USAGE ON SCHEMA bronze, app, silver, gold TO dbt_transform;
GRANT CREATE ON SCHEMA silver, gold TO dbt_transform;
GRANT SELECT ON ALL TABLES IN SCHEMA bronze, app TO dbt_transform;
ALTER DEFAULT PRIVILEGES IN SCHEMA bronze, app GRANT SELECT ON TABLES TO dbt_transform;

-- app_user: lê gold e edita os dados digitados em app
CREATE ROLE app_user LOGIN;
GRANT USAGE ON SCHEMA gold, app TO app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA gold TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
