-- Transações da Pluggy: uma linha por transação, na versão ingerida mais recente

with paginas as (
    select ingerido_em, payload
    from {{ source('bronze', 'pluggy_raw') }}
    where endpoint = 'transactions'
),

transacoes as (
    select
        p.ingerido_em,
        t as transacao
    from paginas as p
    cross join lateral jsonb_array_elements(p.payload -> 'results') as t
),

ultima_versao as (
    select
        *,
        row_number() over (
            partition by transacao ->> 'id'
            order by ingerido_em desc
        ) as versao
    from transacoes
)

select
    transacao ->> 'id'                                         as transacao_id,
    transacao ->> 'accountId'                                  as conta_id,
    ((transacao ->> 'date')::timestamptz
        at time zone 'America/Sao_Paulo')::date                as data,
    transacao ->> 'description'                                as descricao,
    transacao ->> 'type'                                       as tipo,
    -- CREDIT/DEBIT indicam entrada/saída de dinheiro, não o cartão de crédito
    case when transacao ->> 'type' = 'DEBIT' then 'saida' else 'entrada' end as sentido,
    -- sinal vem do tipo: no cartão a Pluggy envia compra com valor positivo
    case when transacao ->> 'type' = 'DEBIT' then -1 else 1 end
        * abs(coalesce(
            (transacao ->> 'amountInAccountCurrency')::numeric,
            (transacao ->> 'amount')::numeric
        ))                                                     as valor,
    transacao ->> 'currencyCode'                               as moeda_original,
    transacao ->> 'category'                                   as categoria,
    transacao ->> 'categoryId'                                 as categoria_id,
    transacao ->> 'status'                                     as status,
    transacao ->> 'operationType'                              as tipo_operacao,
    (transacao -> 'creditCardMetadata' ->> 'installmentNumber')::int as parcela,
    (transacao -> 'creditCardMetadata' ->> 'totalInstallments')::int as total_parcelas,
    transacao -> 'creditCardMetadata' ->> 'billId'             as fatura_id,
    ingerido_em
from ultima_versao
where versao = 1
