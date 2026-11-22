-- Despesas por mês e meio de pagamento (crédito, débito, Pix, boleto)

select
    mes,
    meio_pagamento,
    -sum(valor) as total,
    count(*)    as qtd_transacoes
from {{ ref('fct_transacoes') }}
where natureza = 'despesa'
group by mes, meio_pagamento
