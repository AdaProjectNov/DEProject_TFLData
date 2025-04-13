{{ 
    config( 
        materialized='table',
        partition_by={
            "field": "reading_date",
            "data_type": "date",
            "granularity": "day"
        }, 
        cluster_by=["region", "location_id", "mode"]
    ) 
}} 

with stg_central as (
    select * from {{ ref('stg_tfl_central_data') }}
),

stg_inner as (
    select * from {{ ref('stg_tfl_inner_data') }}
),

stg_outer as (
    select * from {{ ref('stg_tfl_outer_data') }}
),

staged_unioned as (
    -- Union all staging models and add the 'region' column
    select *, 'Central' as region from stg_central
    union all
    select *, 'Inner' as region from stg_inner
    union all
    select *, 'Outer' as region from stg_outer
),

dim_locations as (
    -- Select necessary columns from the location dimension
    select 
        location_id, 
        location_name,
        borough,
        road_type,
        latitude,
        longitude
        -- Select other attributes if needed
    from {{ ref('dim_locations') }}
)

select
    -- Primary key for the fact table
    su.reading_id as cycling_reading_id, 

    -- Foreign key to dim_locations
    su.site_id as location_id, -- Ensure this matches dim_locations.location_id

    -- Degenerate dimensions (attributes from the event itself)
    su.region,
    su.filename,
    su.wave,
    su.weather,
    su.day,
    su.round,
    su.direction,
    su.path,
    su.mode,

    -- Date/Time dimensions
    su.reading_date,
    su.reading_time_str,

    -- Attributes from joined dimensions
    dl.location_name,
    dl.borough,
    dl.road_type,
    dl.latitude as location_latitude,  -- Rename to avoid clash if source had lat/lon
    dl.longitude as location_longitude, -- Rename to avoid clash

    -- Measures / Facts
    su.reading_count

from staged_unioned su
-- Left join to enrich with location data; keeps all readings even if location info is missing
left join dim_locations dl on su.site_id = dl.location_id 

-- Optional: Filter data if needed (e.g., by date)
-- where su.reading_date >= '2019-01-01'

-- Optional: Add test run limit logic
-- {% if var('is_test_run', default=true) %}
--  limit 1000
-- {% endif %}