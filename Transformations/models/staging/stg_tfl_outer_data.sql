{{
    config(
        materialized='view'
    )
}}

with source_data as (
    -- Select data from the Outer region source table
    select * from {{ source('staging', 'tfl_outer_data') }} 
)
select
    -- Identifiers
    unique_row_id as reading_id, 
    siteid as site_id,           -- Rename to standard snake_case

    -- Contextual Information
    filename,
    wave, 
    weather,
    day, 
    round, 
    direction,
    path,
    mode,

    -- Timestamps 
    date as reading_date,      
    time as reading_time_str,  
    count as reading_count     

from source_data

{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}