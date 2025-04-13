# TFL Cycling Data Analysis with dbt & BigQuery

## Project Goal

This project utilizes dbt (Data Build Tool) to extract, transform, and model Transport for London (TFL) cycling count data, ultimately stored in Google BigQuery. The primary objective is to create a clean, reliable, and optimized dataset (`fact_cyclings`) suitable for analyzing cycling patterns across different London regions (Central, Inner, Outer), times, and locations.

## Tech Stack

* **Data Transformation:** dbt
* **Data Warehouse:** Google BigQuery
* **Version Control:** Git / GitHub
* **Static Data:** dbt Seeds (for location lookup table)
* **(Data Extraction - Implied):** Raw data (TFL counts per region) is assumed to exist in BigQuery source tables (potentially loaded by Kestra or other means). Here we use the data loaded by Kestra.

## Project Structure
## Project Structure

```text
.
├── dbt_project.yml         # Main dbt project configuration file
├── packages.yml            # dbt package dependencies (e.g., dbt_utils)
├── screenshots/            # Contains screenshots for README and documentation
├── seeds/                  # Contains static data (CSV) and corresponding config/tests
│   ├── locations_lookup.csv  # Raw data with details for TFL monitoring sites
│   └── locations_lookup.yml  # Configuration, description, and tests for the seed file
└── models/                 # Contains all data transformation logic (SQL files)
    ├── staging/            # Staging layer models: basic cleaning, renaming, type casting
    │   ├── schema.yml          # Descriptions and tests for staging sources and models
    │   ├── stg_tfl_central_data.sql
    │   ├── stg_tfl_inner_data.sql
    │   └── stg_tfl_outer_data.sql
    └── core/               # Core layer models: dimension and fact tables for analysis
        ├── schema.yml          # Descriptions and tests for core models
        ├── dim_locations.sql   # Location dimension table
        └── fact_cyclings.sql   # Cycling count fact table
```

## Models Explained

This project follows a layered modeling approach:

1.  **Seeds (`seeds/`)**:
    * `locations_lookup.csv`: Contains static details about TFL monitoring sites (e.g., Site ID, Borough, Road type, coordinates). Loaded into BigQuery as the `locations_lookup` table using the `dbt seed` command. Its configuration and tests are defined in `seeds/locations_lookup.yml`.

2.  **Staging Layer (`models/staging/`)**:
    * Models in this layer are typically materialized as views (`view`).
    * They read directly from the source data tables loaded into BigQuery by Kestra (defined as `source` in `staging/schema.yml`, e.g., `tfl_central_data`).
    * Primary responsibilities include:
        * Selecting necessary columns.
        * Renaming columns to consistent, understandable names (e.g., `unique_row_id` -> `reading_id`, `Date` -> `reading_date`, `Count` -> `reading_count`).
        * Basic data type checking and casting (though `Date` and `Count` types should already be processed by Kestra).
    * It's important to note that the source data tables ingested by Kestra already include a pre-generated `unique_row_id` (based on a hash of key fields) and the source `filename`. Therefore, the staging models do **not** need to regenerate a unique key (e.g., using `dbt_utils.generate_surrogate_key`) or add the filename again; they simply select and rename these existing fields (e.g., `unique_row_id` is renamed to `reading_id`).
    * Includes three models: `stg_tfl_central_data.sql`, `stg_tfl_inner_data.sql`, `stg_tfl_outer_data.sql`, corresponding to the three regions.

3.  **Core Layer (`models/core/`)**:
    * These are the final core data models intended for analysis and reporting, typically materialized as tables (`table`).
    * **`dim_locations.sql`**:
        * Builds the location dimension table.
        * Reads data from the `locations_lookup` seed table.
        * Performs final column selection and renaming (e.g., using `site_id` as the `location_id` primary key).
        * Provides detailed dimensional information about the monitoring sites.
    * **`fact_cyclings.sql`**:
        * Builds the core cycling count fact table.
        * Uses `UNION ALL` to combine data from the three regional staging models (`stg_tfl_*_data`) and adds a `region` column.
        * Uses `LEFT JOIN` to enrich the combined data with location details (like `borough`, `road_type`, `latitude`, `longitude`, etc.) from the `dim_locations` table based on the site ID.
        * Contains facts (`reading_count`), foreign keys (`location_id`), degenerate dimensions (`region`, `mode`, `weather`, etc.), and time dimensions (`reading_date`, `reading_time_str`).
        * This table is configured to be **partitioned by `reading_date`** and clustered by `region`, `location_id`, `mode` to optimize query performance.

### Data Lineage

The following diagram shows the dependencies between the dbt models:

 ![dbt Model Lineage](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/03_Transformations/screenshots/Data%20Lineage.png) 

## How to Run

### 1. Setup

1.  **Clone Repository:**
    ```bash
    git clone <your-github-repo-url>
    cd <your-repo-name> 
    ```
2.  **Configure dbt Profile:**
    * Ensure your `profiles.yml` file (typically in `~/.dbt/` or managed by dbt Cloud) is correctly configured with a `default` profile connecting to your Google BigQuery project. You need to set the `project`, `dataset`, `method` (authentication), `keyfile` (if using a service account), `location`, etc. Refer to the `profile` setting in `dbt_project.yml`.
3.  **Install Dependencies:**
    * If your `packages.yml` file lists any dependencies (like `dbt_utils`), run:
        ```bash
        dbt deps
        ```

### 2. Run dbt Commands

1.  **Load Seed Data:**
    * Run this command to load `seeds/locations_lookup.csv` into BigQuery:
        ```bash
        dbt seed
        ```
    * (If you encounter permission errors or issues with existing tables, you might need to manually clean up old tables in BigQuery first or use `dbt seed` flags like `--full-refresh`)
2.  **Run Models:**
    * Run all models (Staging and Core):
        ```bash
        dbt run
        ```
    * Alternatively, use `dbt build` to run models, tests, seeds, etc., in the correct order (it typically won't re-run seeds unless necessary or specified):
        ```bash
        dbt build
        ```
    * **Example Success Screenshot for `dbt run` or `dbt build`:**

      ![dbt run/build Success](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/03_Transformations/screenshots/dbt%20run%20success.png) 

3.  **Run Tests:**
    * Run all data quality tests defined in your `schema.yml` files:
        ```bash
        dbt test
        ```
    * Alternatively, use `dbt build`.
    * **Example Success Screenshot for `dbt test` or `dbt build`:**
  
      ![dbt test Success](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/03_Transformations/screenshots/dbt%20test%20success.png) 

## Example Data

Below is a sample screenshot showing data in the final `fact_cyclings` table within BigQuery:

![](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/03_Transformations/screenshots/fact_cyclings%20table%20part%201.png)

![](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/03_Transformations/screenshots/fact_cyclings%20table%20part%202.png)
