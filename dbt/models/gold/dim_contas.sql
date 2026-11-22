-- Dimensão de contas

select
    conta_id,
    item_id,
    tipo,
    subtipo,
    case subtipo
        when 'CHECKING_ACCOUNT' then 'Conta corrente'
        when 'SAVINGS_ACCOUNT' then 'Poupança'
        when 'CREDIT_CARD' then 'Cartão de crédito'
        else subtipo
    end as tipo_conta,
    coalesce(nome_comercial, nome) as nome,
    saldo,
    atualizado_em
from {{ ref('contas') }}
