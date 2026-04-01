-- Configurations: https://docs.getdbt.com/reference/resource-configs/snowflake-configs
{{
    config(
        materialized='table',
        tags='critical',
    )
}}

with parts as (

    select * from {{ ref('snap__part') }} -- /snapshots/snap__part.sql (part snapshot)

),

renamed as (

    select
        p_partkey as part_id,
        initcap(p_name) as name,
        p_brand as brand,
        trim(p_comment) as comment,
        p_size as size,
        p_retailprice as retail_price,
    from
        parts
    where
        dbt_valid_to is null    -- filter to only the snapshot's currently active records
        

)

select * from renamed