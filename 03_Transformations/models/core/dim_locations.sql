{{ config(materialized='table') }}


select

    site_id as location_id, 
    location_description as location_name,
    borough,
    functional_area_for_monitoring as functional_area, 
    road_type,
    is_it_on_the_strategic_cio_panel as strategic_cio_panel_id, 
    old_site_id_legacy as legacy_site_id, 
    easting_uk_grid, 
    northing_uk_grid, 
    latitude, 
    longitude

from {{ ref('locations_lookup') }} 

where site_id is not null