-- Usa o schema configurado (silver, gold) sem prefixar o schema do target
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ (custom_schema_name or target.schema) | trim }}
{%- endmacro %}
