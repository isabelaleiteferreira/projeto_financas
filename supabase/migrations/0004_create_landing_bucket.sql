--- 0004: landing zone no Storage e rastreio do arquivo de origem na bronze

-- bucket privado com os JSON brutos da Pluggy
INSERT INTO storage.buckets (id, name, public)
VALUES ('pluggy-raw', 'pluggy-raw', false)
ON CONFLICT (id) DO NOTHING;

-- caminho do arquivo no bucket; único para impedir carga duplicada
ALTER TABLE bronze.pluggy_raw ADD COLUMN IF NOT EXISTS arquivo text;

CREATE UNIQUE INDEX IF NOT EXISTS pluggy_raw_arquivo_uq
    ON bronze.pluggy_raw (arquivo);

COMMENT ON COLUMN bronze.pluggy_raw.arquivo IS 'Caminho do JSON no bucket pluggy-raw';
