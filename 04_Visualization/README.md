## Visualizations and Analysis

This project utilizes the final `fact_cyclings` core data model to build a series of visualizations in Power BI. The aim is to transform the raw count data into actionable insights to support decisions related to transport and travel in London.

---

### 1. Cycling Count by Location (Map)

* **Type:** Map, with bubble size indicating count.
* **Content:** Plots monitoring site locations (`location_id`) on a map of London, using latitude and longitude. The size of each bubble visually represents the total cycling count (`SUM(reading_count)`) at that location. Colors or filters can be used for borough or region.
* **Purpose & Insights:**
    * **Visualize Spatial Distribution:** Provides an immediate overview of the geographic distribution and density variations of cycling traffic across London.
    * **Identify Hotspots:** Easily identify specific monitoring sites or areas with the highest cycling volume (largest bubbles) and those with lower traffic. This helps pinpoint commute corridors, popular recreational routes, or potential bottlenecks.
    * **Regional Comparison:** Visually compare the overall traffic levels and spatial clustering patterns between Central, Inner, and Outer London.
    * **Support Decision Making:** Offers evidence for urban planners, e.g., where to consider optimizing cycle lanes, adding parking facilities, or adjusting traffic signal timing based on high traffic volumes.

`![Cycling Count by Location Map](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/04_Visualization/CountbyLocations.png)

---

### 2. Cycling Count Proportion by Weather (Pie Chart)

* **Type:** Pie Chart.
* **Content:** Shows the percentage breakdown of the total cycling count (`SUM(reading_count)`) across different recorded weather conditions (`weather`).
* **Purpose & Insights:**
    * **Quantify Weather Impact:** Clearly illustrates the overall impact of good weather (e.g., sunny) versus adverse conditions (e.g., rain, high wind) on people's choice to cycle. For instance, it shows if the proportion of cycling during rainy days is significantly lower.
    * **Assess Resilience:** Understand what proportion of cycling activity persists even during unfavorable weather, indicating the travel needs of a core group of cyclists.
    * **Aid Resource Allocation:** Provides context for transport authorities, e.g., predicting how much cycling demand might decrease during bad weather, potentially informing decisions about increasing public transport capacity or other support measures.

![Cycling Count by Weather Pie Chart](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/04_Visualization/CountbyWeather.png)

---

### 3. Annual Cycling Count Trend by Region (Bar Chart)

* **Type:** Bar Chart (likely clustered or stacked).
* **Content:** X-axis represents the year (extracted from `reading_date`), Y-axis represents the total cycling count (`SUM(reading_count)`), and the legend or colors differentiate the regions (`region`: Central, Inner, Outer).
* **Purpose & Insights:**
    * **Cross-Region Annual Comparison:** Allows easy comparison of total annual cycling volumes across the three regions, identifying the primary cycling areas each year.
    * **Identify Annual Trends:** Observe the year-over-year trend for each region – is cycling volume growing, declining, or stable? Are the growth/decline rates similar across regions?
    * **Evaluate Policy Effects:** If major cycling promotion policies or infrastructure projects were implemented in specific years, this chart can offer a preliminary view of whether cycling volumes changed accordingly in different regions post-implementation.
    * **Support Long-Term Planning:** Provides historical data to support long-term transport planning and resource allocation.

![Annual Count by Region Bar Chart](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/04_Visualization/CountbyYearRegion.png)

---

### 4. Cycling Count by Road Type (Bar Chart)

* **Type:** Bar Chart (more suitable than a line chart for comparing discrete categories).
* **Content:** X-axis represents the type of road (`road_type`, from the `dim_locations` table), Y-axis represents the total cycling count (`SUM(reading_count)`) across all monitoring sites located on that road type.
* **Purpose & Insights:**
    * **Infrastructure Usage Analysis:** Understand which types of roads (e.g., A Roads, Cycleways, Local Streets) accommodate the most cycling traffic.
    * **Assess Facility Effectiveness:** If data shows significantly higher traffic on dedicated cycleways compared to other roads under similar conditions, it can support the case for their effectiveness. Conversely, low usage on certain road types might warrant investigation.
    * **Optimization Suggestions:** Combined with map data, analyzing the distribution of high-traffic road types can inform future planning for the cycle network, connectivity improvements, and road safety enhancements. For example, should safer cycling facilities be added alongside high-traffic A roads?

![Count by Road Type Bar Chart Placeholder](https://raw.githubusercontent.com/AdaProjectNov/DEProject_TFLData/main/04_Visualization/CountofRoadType.png)

---

### Future Outlook & Further Analysis

The current visualization dashboard provides a solid foundation and multi-dimensional insights into cycling patterns in London. Building upon the processed and modeled data (`fact_cyclings` and `dim_locations`), numerous avenues exist for deeper, more advanced analysis, including leveraging machine learning:

1.  **Granular Time Series Analysis:**
    * Utilize `reading_date` and `reading_time_str` (or parsed `reading_time`) to delve into **hourly** traffic variations and identify precise peak morning and evening commute times.
    * Compare cycling patterns between weekdays and weekends, or across different seasons.
    * Visualize detailed time-based trends for specific high-interest sites or routes.

2.  **Advanced Geospatial Analysis:**
    * Overlay cycling counts with more detailed geographic information (e.g., cycle lane quality ratings, gradient/slope, proximity to tube/bus stations, surrounding land use types) using GIS capabilities, potentially generating heatmaps or density maps.
    * Analyze the spatial impact of specific events (e.g., marathons, transit strikes, holidays) on regional cycling traffic.
    * Integrate demographic data to understand cycling characteristics in different neighborhoods.

3.  **External Data Integration:**
    * Combine TFL cycling data with other relevant datasets, such as public transport usage figures, road traffic congestion levels, air quality measurements, or even shared e-bike/e-scooter availability data.
    * Analyze correlations or potential causal relationships between these factors and cycling volumes (e.g., does improved air quality correlate with increased cycling? Do transit fare changes impact cycling choices?).

4.  **Machine Learning Applications:**
    * **Demand Forecasting:** Employ time series models (like ARIMA, Prophet) or more complex deep learning models (like LSTMs) on historical counts, time features, weather data, and location attributes to **predict future cycling traffic** at specific sites or regions. This can inform resource scheduling (e.g., bike-share deployment) and traffic management.
    * **Anomaly Detection:** Automatically identify unusual spikes or dips in traffic counts, helping to flag potential data quality issues, unrecorded special events, or infrastructure failures.
    * **Factor Analysis & Prediction:** Utilize supervised learning models (e.g., Random Forest, Gradient Boosting) to **quantify the impact of various factors** (weather, time of day, day of week, location features) on cycling volume. These models could even predict the expected traffic level (classification) or count (regression) under specific conditions.


By pursuing these advanced analyses and applying machine learning techniques, the understanding of urban cycling behavior can be significantly deepened, providing powerful data support for building smarter, friendlier, and more efficient city transportation systems.
