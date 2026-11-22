-- Dimensão do plano de contas gerencial

select
    natureza,
    nome,
    grupo,
    entra_no_resultado,
    ordem
from {{ ref('plano_contas') }}
