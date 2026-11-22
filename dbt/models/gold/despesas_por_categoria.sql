-- Despesas por mês, grupo e categoria (valores positivos)

select
    f.mes,
    coalesce(c.grupo, 'Sem categoria')     as grupo,
    coalesce(c.categoria, 'Sem categoria') as categoria,
    -sum(f.valor)                          as total,
    count(*)                               as qtd_transacoes
from {{ ref('fct_transacoes') }} as f
left join {{ ref('dim_categorias') }} as c
    on c.categoria_id = f.categoria_id
where f.natureza = 'despesa'
group by 1, 2, 3
