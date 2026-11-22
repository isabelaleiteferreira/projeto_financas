-- Fato de transações: uma linha por transação, com natureza e mês de competência

select
    t.transacao_id,
    t.conta_id,
    t.categoria_id,
    t.data,
    date_trunc('month', t.data)::date as mes,
    t.descricao,
    t.valor,
    t.tipo,
    t.status,
    t.parcela,
    t.total_parcelas,
    coalesce(c.natureza, 'despesa')  as natureza
from {{ ref('transacoes') }} as t
left join {{ ref('dim_categorias') }} as c
    on c.categoria_id = t.categoria_id
