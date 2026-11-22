-- Fato de transações: uma linha por transação, com sentido, meio de pagamento e natureza

with base as (
    select
        t.*,
        c.subtipo as subtipo_conta
    from {{ ref('transacoes') }} as t
    left join {{ ref('contas') }} as c
        on c.conta_id = t.conta_id
)

select
    b.transacao_id,
    b.conta_id,
    b.categoria_id,
    b.data,
    date_trunc('month', b.data)::date as mes,
    b.descricao,
    b.valor,
    b.sentido,
    case
        when b.subtipo_conta = 'CREDIT_CARD' then 'Crédito'
        when b.tipo_operacao = 'PIX' then 'Pix'
        when b.tipo_operacao = 'BOLETO' then 'Boleto'
        when b.tipo_operacao like 'TRANSFERENCIA%'
            or b.tipo_operacao in ('TED', 'DOC') then 'Transferência'
        when b.sentido = 'saida' then 'Débito'
        else 'Outros'
    end as meio_pagamento,
    -- exceção por categoria e sentido prevalece sobre a natureza do grupo
    coalesce(e.natureza, c.natureza, 'despesa') as natureza,
    b.status,
    b.parcela,
    b.total_parcelas
from base as b
left join {{ ref('dim_categorias') }} as c
    on c.categoria_id = b.categoria_id
left join {{ ref('natureza_categorias') }} as e
    on e.categoria_id = b.categoria_id
    and e.sentido = b.sentido
