-- Receitas, rendimentos, despesas e resultado por mês
-- transferências e investimentos ficam fora para não contar o mesmo dinheiro duas vezes

select
    mes,
    coalesce(sum(valor) filter (where natureza = 'receita'), 0)    as receitas,
    coalesce(sum(valor) filter (where natureza = 'rendimento'), 0) as rendimentos,
    coalesce(-sum(valor) filter (where natureza = 'despesa'), 0)   as despesas,
    sum(valor)                                                     as resultado
from {{ ref('fct_transacoes') }}
where natureza in ('receita', 'rendimento', 'despesa')
group by mes
