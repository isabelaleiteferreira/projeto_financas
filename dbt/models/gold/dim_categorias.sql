-- Dimensão de categorias com grupo e natureza financeira

select
    c.categoria_id,
    c.nome          as categoria,
    c.grupo_id,
    c.grupo,
    coalesce(n.natureza, 'despesa') as natureza
from {{ ref('categorias') }} as c
left join {{ ref('natureza_grupos') }} as n
    on n.grupo_id = c.grupo_id
