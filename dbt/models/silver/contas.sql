-- Contas da Pluggy: uma linha por conta, no snapshot mais recente
-- owner e taxNumber ficam de fora (dados pessoais)

with snapshots as (
    select
        r.ingerido_em,
        c as conta
    from {{ source('bronze', 'pluggy_raw') }} as r
    cross join lateral jsonb_array_elements(r.payload -> 'results') as c
    where r.endpoint = 'accounts'
),

ultima_versao as (
    select
        *,
        row_number() over (
            partition by conta ->> 'id'
            order by ingerido_em desc
        ) as versao
    from snapshots
)

select
    conta ->> 'id'                as conta_id,
    conta ->> 'itemId'            as item_id,
    conta ->> 'type'              as tipo,
    conta ->> 'subtype'           as subtipo,
    conta ->> 'name'              as nome,
    conta ->> 'marketingName'     as nome_comercial,
    (conta ->> 'balance')::numeric as saldo,
    conta ->> 'currencyCode'      as moeda,
    ingerido_em                   as atualizado_em
from ultima_versao
where versao = 1
