-- Categorias da Pluggy com o grupo de nível superior (dois primeiros dígitos do id)

with snapshots as (
    select
        r.ingerido_em,
        c as categoria
    from {{ source('bronze', 'pluggy_raw') }} as r
    cross join lateral jsonb_array_elements(r.payload -> 'results') as c
    where r.endpoint = 'categories'
),

ultima_versao as (
    select
        categoria ->> 'id'                    as categoria_id,
        categoria ->> 'descriptionTranslated' as nome,
        categoria ->> 'description'           as nome_original,
        row_number() over (
            partition by categoria ->> 'id'
            order by ingerido_em desc
        ) as versao
    from snapshots
)

select
    filha.categoria_id,
    filha.nome,
    filha.nome_original,
    -- categoria sem grupo pai (ex.: 99999999 Outros) é o próprio grupo
    coalesce(grupo.categoria_id, filha.categoria_id) as grupo_id,
    coalesce(grupo.nome, filha.nome)                 as grupo
from ultima_versao as filha
left join ultima_versao as grupo
    on grupo.categoria_id = left(filha.categoria_id, 2) || '000000'
    and grupo.versao = 1
where filha.versao = 1
