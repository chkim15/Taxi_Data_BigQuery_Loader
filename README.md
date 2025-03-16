# Taxi Data BigQuery Loader

This repository contains scripts and configuration to load taxi data from a PostgreSQL dump into Google BigQuery.

## Project Overview

The project handles two main tables:
- `taxi_search_history`: Contains search history data for taxi services
- `taxi_request`: Contains taxi request data

The data originates from a large PostgreSQL dump file (382 GB) that was processed and loaded into BigQuery.

## Repository Structure

```
taxi-data-bigquery/
├── config/
│   ├── schema_taxi_search_history.json
│   ├── schema_taxi_search_history_fixed.json
│   ├── schema_taxi_request.json
│   └── schema_taxi_request_fixed.json
├── data/
│   ├── processed/
│   └── raw/
├── logs/
├── scripts/
│   ├── process_sql_dump.py
│   ├── load_to_bigquery.py
│   ├── load_from_gcs.py
│   ├── load_taxi_search_history.py
│   ├── load_taxi_search_headerless.py
│   ├── create_and_load_with_header.py
│   ├── run_pipeline.py
│   └── utils/
│       └── sql_parser.py
├── bigquery_transform_sql/
│   ├── 01_remove_bot_users.sql
│   ├── 02_filter_8_cities.sql
│   ├── 03_only_uberx_lyft_standard.sql
│   ├── 04_delete_more_than_10_same_requests.sql
│   ├── 05_create_region.sql
│   ├── 06_add_place_category.sql
│   ├── 07_create_analysis_dataset.sql
│   ├── 08_create_analysis_2_dataset.sql
├── README.md
└── requirements.txt
```

## Setup and Installation

1. Clone this repository
2. Create a Python virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Configure Google Cloud credentials

## Data Processing Pipeline

The pipeline consists of two main steps:

1. **Data Extraction**: Extracting table data from the PostgreSQL dump file
   - Process: The script reads through the SQL file and extracts data in the PostgreSQL COPY format
   - Output: CSV files for each table in the `data/processed/` directory
   - Command: `python scripts/process_sql_dump.py --sql_file /path/to/out.sql`

2. **Data Loading**: Loading the processed CSV files to BigQuery
   - Process: Upload the CSV files to Google Cloud Storage, then load to BigQuery
   - Command: `python scripts/load_to_bigquery.py --bucket your-bucket --dataset your-dataset --credentials /path/to/credentials.json`

### Challenges and Solutions

1. **Large File Size**: The PostgreSQL dump file is 382 GB, and the extracted CSV files are also very large
   - Solution: Streaming extraction from SQL file to avoid loading entire file into memory

2. **Array Fields**: The `taxi_search_history` table contains array fields which are not directly compatible with CSV format
   - Solution: Modified schema to treat arrays as STRING type in BigQuery

3. **BigQuery File Size Limits**: BigQuery has a 4 GB file size limit for certain loading operations
   - Solution: Used BigQuery's SQL LOAD DATA approach which handles larger files better

4. **Column Count Mismatch**: The `taxi_request` table had more columns in the CSV than in the initial schema
   - Solution: Updated schema to include all 62 columns

5. **Header Row Issues**: The PostgreSQL COPY format doesn't include column headers
   - Solution: Created separate header files and used them during the loading process

## Usage

### Full Pipeline

```bash
python scripts/run_pipeline.py --sql_file /path/to/out.sql --bucket your-bucket --dataset your-dataset --credentials /path/to/credentials.json
```

### Individual Steps

1. Process SQL dump:
```bash
python scripts/process_sql_dump.py --sql_file /path/to/out.sql
```

2. Load to BigQuery (if files are already in GCS):
```bash
python scripts/load_from_gcs.py --bucket your-bucket --dataset your-dataset --credentials /path/to/credentials.json
```

3. Load just the taxi_search_history table:
```bash
python scripts/load_taxi_search_history.py --bucket your-bucket --dataset your-dataset --credentials /path/to/credentials.json
```

## Notes

- Make sure your GCP service account has proper permissions:
  - BigQuery Admin or BigQuery Data Editor + Job User
  - Storage Admin or Storage Object Admin
  
- For large files, the loading process can take a significant amount of time

- All scripts include error handling and logging to help with troubleshooting

### BigQuery SQL Files Summary

The project includes several SQL files that process and transform the taxi data:

1. **01_remove_bot_users.sql**: Filters out bot users and competitor IDs, focusing on US geographic coordinates.

2. **02_filter_8_cities.sql**: Limits data to 8 major US cities (Boston, NYC, Chicago, LA, Miami, Seattle, Minneapolis, Houston).

3. **03_only_uberx_lyft_standard.sql**: Creates dataset with searches containing both UberX and Lyft, filtered by distance and price.

4. **04_delete_more_than_10_same_requests.sql**: Reduces redundancy by keeping only the first 5 identical route requests per user per day.

5. **05_create_region.sql**: Establishes reference table with city centers and airport coordinates for the 8 cities.

6. **06_add_place_category.sql**: Categorizes locations as "airport", "city center", or "outside city center" based on coordinates.

7. **07_create_analysis_dataset.sql**: Transforms data with local timestamps, day/hour information, and price calculations.

8. **08_create_analysis_2_dataset.sql**: Creates comparison table with UberX and Lyft prices side-by-side for direct analysis.
