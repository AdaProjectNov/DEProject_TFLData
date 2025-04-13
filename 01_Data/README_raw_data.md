# Raw Data Documentation - London Bicycle Traffic

This document describes the structure, format, and usage of the raw data files used in the **London Bicycle Traffic Analysis & Data Engineering Project**.

---

## File Naming Convention

All raw `.csv` files follow the naming format:


### Components:

- **`<year>`**: Year of data collection, e.g., `2023`
- **`<quarter>`**: One of `Q1`, `Q2`, `Q3`, `Q4`
- **`<region>`**: Geographical region, typically one of:
  - `central`
  - `inner`
  - `outer`

### Example Filenames:

- `2022_Q2-central.csv`
- `2023_Q1-inner.csv`
- `2023_Q3-outer.csv`

These files are published quarterly and each one corresponds to a set of monitored sites within a region.

---

## CSV Column Structure

Each file contains consistent column names, as shown below:

| Column Name | Type     | Description |
|-------------|----------|-------------|
| `Wave`      | String   | Collection cycle or batch of data (used for tracking source wave) |
| `SiteID`    | String   | Unique identifier for each monitoring site |
| `Date`      | Date     | Calendar date of observation (`DD/MM/YYYY`) |
| `Weather`   | String   | Weather condition on that day (`Dry`, `Wet`, etc.) |
| `Time`      | String   | Time of observation (e.g., `08:00`, `14:30`) |
| `Day`       | String   | Day of the week (`Weekday`etc.) |
| `Round`     | String   | Survey round or batch (may repeat across quarters) |
| `Direction` | String   | Direction of cycling traffic (`Northbound`, `Southbound`, etc.) |
| `Path`      | String   | Path or street where the count occurred |
| `Mode`      | String   | Mode of travel (`Private cycles`, `Cycle hire bikes`, etc.) |
| `Count`     | INT64    | Number of cyclists observed for the specific time and direction |

> All files are encoded in UTF-8 and use commas as the delimiter.




