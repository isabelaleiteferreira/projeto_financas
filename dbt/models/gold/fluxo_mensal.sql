-- Entradas, saídas e resultado por mês, sem transferências e investimentos

select
    mes,
    sum(valor) filter (where valor > 0)       as entradas,
    -sum(valor) filter (where valor < 0)      as saidas,
    sum(valor)                                as resultado,
    count(*)                                  as qtd_transacoes
from {{ ref('fct_transacoes') }}
where natureza in ('receita', 'despesa')
group by mes
