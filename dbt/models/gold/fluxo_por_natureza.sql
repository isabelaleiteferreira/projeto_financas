-- Visão completa do mês por grupo e natureza, incluindo movimentações internas

select
    f.mes,
    n.grupo,
    n.nome                                         as natureza,
    n.ordem,
    n.entra_no_resultado,
    coalesce(sum(f.valor) filter (where f.sentido = 'entrada'), 0)  as entradas,
    coalesce(-sum(f.valor) filter (where f.sentido = 'saida'), 0)   as saidas,
    sum(f.valor)                                   as saldo,
    count(*)                                       as qtd_transacoes
from {{ ref('fct_transacoes') }} as f
inner join {{ ref('dim_natureza') }} as n
    on n.natureza = f.natureza
group by 1, 2, 3, 4, 5
