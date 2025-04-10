{{
    config(
        materialized='view' 
    )
}}

with source_data as (
    -- Select data from the source table defined in sources.yml
    select * from {{ source('staging', 'tfl_central_data') }} 
)
select
    -- Identifiers
    unique_row_id as reading_id, -- Rename the unique key from Kestra
    siteid as site_id,           -- Rename to standard snake_case (ensure source table uses 'siteid' or adjust select)

    -- Contextual Information
    filename,
    wave, 
    weather,
    day, 
    round, 
    direction,
    path,
    mode,

    -- Timestamps (Date is already DATE, Time is STRING)
    date as reading_date,      -- Rename Date column
    time as reading_time_str,  -- Rename Time column (keeping as STRING)
    count as reading_count     -- Rename Count column

from source_data

-- No deduplication needed here as Kestra's MERGE should handle uniqueness based on unique_row_id

-- Apply limit for test runs using dbt variables
-- dbt run --select stg_tfl_central_data --vars '{ "is_test_run": false }'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}