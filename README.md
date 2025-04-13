# London Bicycle Traffic Analysis & Data Engineering Project
## Problem Statement

The London urban cycling system is influenced by various factors, including weather conditions, time of day, cycling direction, and region (Central, Inner, Outer). Understanding how these factors interact and affect bicycle traffic is essential for optimizing infrastructure, informing transportation policy, and promoting sustainable urban mobility.

This project aims to analyze bicycle traffic across different regions and time periods in London, and build a complete data pipeline to automate data processing and analysis.

### Future Development Goals:
- Build a predictive model to forecast bicycle traffic trends under different conditions.
- Analyze the impact of weather on cycling volume and explore alternative commuting methods during adverse weather.
- Calculate the utilization rate of cycling lanes to support infrastructure expansion and policy-making.

---

## Key Features

### ELT Data Pipeline

- **Data Extraction**: Automatically extract quarterly-updated cycling traffic data, including date, time, weather, direction, region, and counts. Data is categorized by central, inner (spring), outer (spring), and cycle (spring/autumn).
- **Data Storage**: Store raw data in **Google Cloud Storage (GCS)** and load it into **BigQuery** for high-performance querying.
- **Data Transformation**: Use **dbt (Data Build Tool)** to model the data, converting it into standardized **fact** and **dimension** tables.
- **Data Update**: The pipeline runs **quarterly** to retrieve and incrementally update the latest data.

---

## Data Analysis & Visualization

- **Trend Analysis**
  - Analyze traffic trends by hour/day/week/month
  - Identify peak traffic hours

- **Regional Flow Comparison**
  - Compare ridership across **Central**, **Inner**, and **Outer** zones
  - Identify high-demand areas

- **Weather Impact Evaluation**
  - Analyze traffic variations under sunny, rainy, and cloudy conditions
  - Evaluate how weather affects bike usage to inform public transit support strategies

- **Cycling Distance Metrics**
  - Calculate daily total **Cycle-km** (total distance cycled)
  - Calculate **Cycle-km/km** (cycling intensity) to assess infrastructure utilization

- **Forecasting & Optimization**
  - Build time-series models to forecast future trends
  - Suggest where to expand bike lanes or optimize bike-sharing distribution

- **Visualization**
  - Use **Power BI** to build interactive dashboards for trend analysis, regional comparison, and weather impact

---

## Data Source

- **Source**: Transport for London (TfL) and other citywide cycling traffic monitoring points
- **Content**: Includes date, time, weather, region, direction, and volume
- **Update Frequency**: Released quarterly with a delay
- **License**: Open Government License (OGL) – suitable for analysis and research

---

## Methodology & Workflow

A **batch ELT pipeline** is designed using **Kestra** and **dbt**, with data analyzed in **BigQuery**.

### 1. Data Extraction
- Use **Kestra** to fetch raw CSV files from **GCS**
- Automatically extract time and region from filenames
- Clean and preprocess data (handle missing values, correct formats)

### 2. Data Loading
- Load processed data into **BigQuery**, partitioned by date and region for performance

### 3. Data Transformation
- Use **dbt** for modeling:
  - **Fact table** (`fact_cyclings`) – daily/hourly cycling volumes for different regions
  - **Dimension tables** (e.g. `dim_location`) – contextual info
  - Metrics: **Cycle-km**, **Cycle-km/km**, peak hour counts

### 4. Visualization
- Use **Power BI** to visualize insights:
  - Time trends (hourly, daily, weekly, monthly)
  - Regional comparison
  - Weather impact

---

## Tech Stack

| Component         | Tool                       |
|------------------|----------------------------|
| Storage          | Google Cloud Storage (GCS) |
| Data Warehouse   | BigQuery (partitioned)     |
| Workflow Engine  | Kestra                     |
| Data Modeling    | dbt                        |
| Visualization    | Power BI                   |

---

## Deployment Workflow

1. **Infrastructure Setup**
   - Use **Terraform** to provision GCP resources (GCS, BigQuery)
   - Configure **Kestra** for automated pipeline runs

2. **Pipeline Execution**
   - **Kestra** triggers data ingestion to BigQuery (Partitioning and Clustering are used for tables)
   - **dbt** transforms data into analytical models

3. **Visualization**
   - Connect **Power BI** to BigQuery for real-time dashboards

4. **Automation**
   - Schedule **Kestra** to run **quarterly**, ensuring fresh data

---

## Final Goal

This project helps:
- **City planners** improve infrastructure
- **Governments** decide where to expand bike lanes
- **Bike-sharing companies** optimize fleet operations

All toward creating a **more sustainable urban transportation system**.

---

