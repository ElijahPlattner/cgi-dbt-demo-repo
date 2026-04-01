-- NOTE: because this model uses the format_currency macro at /macros/format_currency.sql, which then references the 
--       usd_currency_conversion seed at /seeds/usd_currency_conversion.csv,
--       we need to manually let dbt know that in some way this model references that seed so that it can detect the dependency -
--       otherwise there will be an error on build. Do this with the "depends_on" comment below:

-- depends_on: {{ ref('usd_currency_conversion') }}

with lineitem as (

    select * from {{ ref('stg__lineitem') }}

),

part as (
    select * from {{ ref('stg__part')}}
),

-- combine final customer information
lineitem_info as (

    select
        lineitem.order_id || '-' || lineitem.line_number as order_line_number_id, -- build composite key with order + line number to use as unique key
        lineitem.order_id,
        lineitem.ship_mode,
        lineitem.receipt_date,
        lineitem.quantity,
        part.name,

        -- get amount in default configured currency, after multiplying by conversion factor (macro at: /macros/format_currency.sql)
        {{ format_currency('extended_price', var('default_currency_type')) }} as extended_price
    from
        lineitem
    join part 
        on lineitem.part_id = part.part_id

)

select * from lineitem_info