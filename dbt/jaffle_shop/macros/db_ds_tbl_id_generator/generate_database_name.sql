{% macro generate_database_name(custom_database_name=none, node=none) -%}

    {% set env_mapping = {
        'sbx': {
            'staging': 'dbt-demos-6ad5',
            'intermediate': 'dbt-demos-6ad5',
            'datamart': 'dbt-demos-6ad5',
            'seeds': 'dbt-demos-6ad5',
            'monitoring': 'dbt-demos-6ad5'
        },
        'prd': {
            'staging': 'dbt-demos-6ad5',
            'intermediate': 'dbt-demos-6ad5',
            'datamart': 'dbt-demos-6ad5',
            'seeds': 'dbt-demos-6ad5',
            'monitoring': 'dbt-demos-6ad5'
        }
    } %}

    {% set environment = 'sbx' if 'sbx' in target.name else 'prd' if 'prd' in target.name else none %}
    {% set is_monitoring = 'elementary' in node.fqn[0] or 'dbt_project_evaluator' in node.fqn %}
    {% set is_analysis = ('analysis' in node.fqn) and not is_monitoring %}
    {% set layer = 'monitoring' if is_monitoring else 'staging' if 'staging' in node.fqn or is_analysis else 'intermediate' if 'intermediate' in node.fqn else 'datamart' if 'datamart' in node.fqn else 'seeds' if node.resource_type == 'seed' else 'test' if node.resource_type == 'test' else none %}

    {% if 'hooks' in node.fqn %}
        {{- target.database | trim -}}
    {% elif environment and layer %}
        {{- env_mapping[environment][layer] -}}
    {% else %}
        {{ exceptions.raise_compiler_error("{{ node.resource_type | capitalize }} '{{ node.unique_id }}' unable to resolve database name.") }}
    {% endif %}

{%- endmacro %}