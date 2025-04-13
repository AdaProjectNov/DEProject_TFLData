# Kestra TFL Data to GCP ETL Pipeline

This project uses Kestra to build a data pipeline that periodically extracts Transport for London (TfL) data from a GitHub repository, loads it into Google Cloud Storage (GCS), and then processes and merges it into Google BigQuery.

The project consists of three Kestra Flows:

1.  `de_project_gcp_kv`: Sets up GCP-related configuration in Kestra's Key-Value (KV) store.
2.  `gcp_setup`: Creates the necessary resources (GCS bucket and BigQuery dataset) in GCP.
3.  `tfl_github_to_gcp_to_bq_schedule`: The main ETL flow responsible for fetching data from GitHub, uploading to GCS, transforming and merging in BigQuery, configured with scheduled triggers.

## Features Overview

This Kestra pipeline implements the following functionalities:

* **Automated Configuration Management**: Securely stores GCP credentials and configuration parameters using the Kestra KV Store.
* **Infrastructure as Code**: Automatically creates the required GCS bucket and BigQuery dataset via a Kestra Flow.
* **Data Extraction**: Downloads TfL CSV data files from a specified GitHub repository, segmented by year, quarter, and region.
* **Data Loading**: Uploads the downloaded data files to a GCS bucket.
* **Data Transformation and Loading (ETL)**:
    * Creates an external table in BigQuery pointing to the CSV file in GCS.
    * Loads data from the external table into a temporary BigQuery table, performing data cleansing (like date format conversion) and generating a unique row identifier (`unique_row_id`) to handle duplicates.
    * Creates the main BigQuery table if it doesn't exist, with **meaningful partitioning and clustering** to optimize downstream queries (details in Flow Description).
    * Uses a `MERGE` statement to merge data from the temporary table into the main table based on the `unique_row_id`, ensuring idempotency and avoiding duplicate inserts.
* **Automated Scheduling**: Configures quarterly scheduled triggers to automatically run the data ingestion process for different regions (Central, Inner, Outer).
* **Resource Cleanup**: Cleans up temporary files stored internally by Kestra after each successful flow execution.

## Flow Details

### 1. `de_project_gcp_kv`

* **Namespace**: `tfl`
* **ID**: `de_project_gcp_kv`
* **Purpose**: This flow stores GCP service account credentials, project ID, location, GCS bucket name, and BigQuery dataset name in the Kestra KV Store. This allows other flows to securely reference these configuration values without hardcoding them.
* **How to Run**: Typically run once for initial setup, or whenever configuration needs updating.
* **Key Tasks**:
    * `gcp_creds`: Stores the GCP service account key in JSON format. **Note**: The `private_key` in the YAML example is truncated; you need to replace it with your complete private key.
    * `gcp_project_id`: Stores the GCP Project ID. **Note**: Modify the `value` according to your environment.
    * `gcp_location`: Stores the GCP location for resources (e.g., `europe-west2`).
    * `gcp_bucket_name`: Stores the GCS bucket name for data storage. **Note**: Bucket names must be globally unique; modify the `value` as needed.
    * `gcp_dataset`: Stores the name of the BigQuery dataset to be created.

### 2. `gcp_setup`

* **Namespace**: `tfl`
* **ID**: `gcp_setup`
* **Purpose**: This flow creates the underlying infrastructure required by the ETL process on Google Cloud Platform. It reads configuration values set previously in the KV Store by the `de_project_gcp_kv` flow.
* **Is it Necessary?**: **Yes, this flow is necessary** (unless you have already manually created the GCS bucket and BigQuery dataset with the same names in GCP). It ensures that the target bucket and dataset exist when the main data pipeline (`tfl_github_to_gcp_to_bq_schedule`) runs.
* **How to Run**: Run this flow once after running `de_project_gcp_kv` and before running the main ETL flow for the first time. Since tasks use `ifExists: SKIP`, rerunning this flow will not cause errors; it will skip the creation of already existing resources.
* **Key Tasks**:
    * `create_gcs_bucket`: Creates the GCS bucket using `GCP_BUCKET_NAME` from the KV Store.
    * `create_bq_dataset`: Creates the BigQuery dataset using `GCP_DATASET` from the KV Store.
* **Flow Diagram (Placeholder)**:
    ```
    [Insert Kestra UI topology view screenshot for gcp_setup Flow here]
    ```

### 3. `tfl_github_to_gcp_to_bq_schedule`

* **Namespace**: `tfl`
* **ID**: `tfl_github_to_gcp_to_bq_schedule`
* **Purpose**: This is the core ETL (Extract, Transform, Load) flow. It downloads the corresponding TfL data from GitHub based on input year, quarter, and region, uploads it to GCS, and then processes and stores it in BigQuery.
* **Inputs**:
    * `year`: Year (e.g., "2015", "2016", ...)
    * `quarter`: Quarter (e.g., "Q1", "Q2", ...)
    * `region`: Region (e.g., "Central", "Inner", "Outer")
* **Variables**: Internal variables are defined within the flow to dynamically generate filenames, GCS paths, and BigQuery table names.
* **Key Tasks**:
    1.  `set_label`: Adds labels to the Kestra execution for easier identification.
    2.  `extract`: Uses `wget` to download the specified CSV file from the GitHub repository.
    3.  `upload_to_gcs`: Uploads the downloaded CSV file to the GCS bucket.
    4.  `create_external_table`: Creates an external table in BigQuery pointing to the file in GCS for querying.
    5.  `create_temp_table`: Reads data from the external table and creates a temporary BigQuery table. In this step:
        * Parses the date string into a `DATE` type.
        * Calculates an MD5 hash based on multiple fields (Date, SiteID, Time, Path, Direction, Round) to generate `unique_row_id` for subsequent data merging and deduplication.
        * Adds a `filename` field to track the source file.
    6.  `create_main_table_if_not_exist`: Creates the target main table (partitioned by region) if it doesn't already exist.
        * **Table Structure Optimization**: The table is **partitioned by `Date` (`PARTITION BY Date`)** and **clustered by `SiteID` and `Mode` (`CLUSTER BY SiteID, Mode`)**.
        * **Partitioning Explained**: Partitioning by `Date` means data is physically stored based on the date. When downstream queries filter by a specific date range (e.g., querying data for a specific month or year), BigQuery only needs to scan the relevant partitions. This significantly reduces the amount of data scanned, lowering query costs and improving performance, especially effective for time-series data.
        * **Clustering Explained**: Within each date partition, data is physically sorted and organized based on the values in the `SiteID` and `Mode` columns. When downstream queries filter, aggregate, or join based on `SiteID` (e.g., analyzing data for a specific site) or `Mode` (e.g., comparing counts for different transport modes), clustering allows BigQuery to find the relevant data more quickly by co-locating related rows, further enhancing query efficiency.
    7.  `merge_data`: Uses a `MERGE` statement to merge data from the temporary table (`S`) into the main table (`T`).
        * `ON T.unique_row_id = S.unique_row_id`: Matches rows based on the unique ID.
        * `WHEN NOT MATCHED THEN INSERT ...`: If a record with the unique ID doesn't exist in the main table, insert the new row. This ensures the idempotency of the data loading process; rerunning the flow with the same data will not insert duplicate records.
    8.  `purge_temp`: Cleans up temporary files generated by Kestra during this execution.
* **Triggers**:
    * Includes three `Schedule` type triggers (`central_quarterly_trigger`, `inner_quarterly_trigger`, `outer_quarterly_trigger`).
    * Each trigger fires at a specific time (9 AM, 10 AM, 11 AM) on the first day of each quarter (Jan 1st, Apr 1st, Jul 1st, Oct 1st).
    * The triggers automatically calculate the year and quarter of the *previous* quarter to use as input parameters for the flow, enabling automated quarterly data imports. For example, the trigger on April 1st will process Q1 data. The trigger on January 1st will process Q4 data from the previous year.
* **Flow Diagram**:
    ```
    ![Kestra Flow Diagram](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/blob/main/02_Workflow/flows/Images/kestra_flow.png) 
    ```

* **Successful Execution Example**:
    ```
    [Insert Kestra UI Gantt chart or log screenshot for successful tfl_github_to_gcp_to_bq_schedule Flow execution here]
    ```

## Setup and Execution Order

1.  **Prepare GCP Service Account**: Ensure you have a GCP service account with the necessary permissions to access GCS and BigQuery (e.g., `Storage Admin`, `BigQuery Admin`, or more granular permissions). Download the JSON key file for this service account.
2.  **Configure `de_project_gcp_kv`**:
    * Open the `de_project_gcp_kv.yml` file.
    * Paste the **entire content** of the downloaded GCP service account JSON key file into the `value` field of the `gcp_creds` task (pay attention to YAML formatting, especially the multiline string `|`).
    * Update the `value` of `gcp_project_id` to your GCP project ID.
    * Update the `value` for `gcp_location`, `gcp_bucket_name`, and `gcp_dataset` as needed. Ensure `gcp_bucket_name` is globally unique.
    * Upload this flow to Kestra and run it once.
3.  **Create GCP Resources**:
    * Upload the `gcp_setup.yml` flow to Kestra.
    * Run the `gcp_setup` flow once. Kestra will use the configuration from the KV Store to create the GCS bucket and BigQuery dataset in GCP.
4.  **Deploy and Run the Main ETL Flow**:
    * Upload the `tfl_github_to_gcp_to_bq_schedule.yml` flow to Kestra.
    * You can manually trigger this flow via the Kestra UI, selecting specific `year`, `quarter`, and `region` values for testing or backfilling historical data.
    * The scheduled triggers configured in the flow will automatically run at the specified times to import the latest quarterly data.

## Important Notes

* **GCP Credential Security**: The `de_project_gcp_kv` flow stores your GCP credentials in Kestra's KV Store. Ensure your Kestra instance is secured appropriately.
* **GCS Bucket Uniqueness**: GCS bucket names must be globally unique. If the name you set in `de_project_gcp_kv` is already taken, the `gcp_setup` flow might fail (or skip creation if `ifExists: SKIP` is effective).
* **Idempotency**: The `MERGE` operation in the main ETL flow ensures data loading is idempotent. Rerunning the flow for the same data period will not result in duplicate records.
* **Resource Costs**: Running BigQuery queries and storing data in GCP incurs costs. Monitor your GCP billing and usage.
