# scripts/load_taxi_search_history.py
#!/usr/bin/env python3
"""
Script to load only the taxi_search_history table with properly handled array fields.
"""
import os
import sys
import json
import logging
import argparse
from google.cloud import bigquery

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/taxi_search_history_loading.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

def create_fixed_schema():
    """Create a fixed schema for taxi_search_history with array fields as STRING."""
    # Original schema from SQL dump
    schema = [
        {"name": "search_id", "type": "STRING", "mode": "REQUIRED"},
        {"name": "user_id", "type": "STRING", "mode": "REQUIRED"},
        {"name": "requested_at", "type": "TIMESTAMP", "mode": "REQUIRED"},
        {"name": "service_provider", "type": "STRING", "mode": "REQUIRED"},
        {"name": "product_name", "type": "STRING", "mode": "REQUIRED"},
        {"name": "pickup_address", "type": "STRING", "mode": "REQUIRED"},
        {"name": "pickup_lat", "type": "NUMERIC", "mode": "REQUIRED"},
        {"name": "pickup_lng", "type": "NUMERIC", "mode": "REQUIRED"},
        {"name": "destination_address", "type": "STRING", "mode": "REQUIRED"},
        {"name": "destination_lat", "type": "NUMERIC", "mode": "REQUIRED"},
        {"name": "destination_lng", "type": "NUMERIC", "mode": "REQUIRED"},
        {"name": "currency", "type": "STRING", "mode": "NULLABLE"},
        {"name": "price_min", "type": "NUMERIC", "mode": "NULLABLE"},
        {"name": "price_max", "type": "NUMERIC", "mode": "NULLABLE"},
        {"name": "eta_seconds", "type": "INTEGER", "mode": "NULLABLE"},
        {"name": "surge_multiplier", "type": "NUMERIC", "mode": "NULLABLE"},
        {"name": "service_level", "type": "STRING", "mode": "NULLABLE"},
        {"name": "distance_meters", "type": "INTEGER", "mode": "NULLABLE"},
        {"name": "duration_seconds", "type": "INTEGER", "mode": "NULLABLE"},
        {"name": "price_min_discounted", "type": "NUMERIC", "mode": "NULLABLE"},
        {"name": "price_max_discounted", "type": "NUMERIC", "mode": "NULLABLE"},
        {"name": "data_source", "type": "STRING", "mode": "NULLABLE"},
        {"name": "region", "type": "STRING", "mode": "NULLABLE"},
        {"name": "pickup_place_types", "type": "STRING", "mode": "NULLABLE"},  # Changed from REPEATED
        {"name": "destination_place_types", "type": "STRING", "mode": "NULLABLE"},  # Changed from REPEATED
        {"name": "session_id", "type": "STRING", "mode": "NULLABLE"},
        {"name": "auto_refreshed", "type": "BOOLEAN", "mode": "NULLABLE"},
        {"name": "eta_seconds_max", "type": "INTEGER", "mode": "NULLABLE"},
        {"name": "discount_type", "type": "STRING", "mode": "NULLABLE"},
        {"name": "provider_connection_user_id", "type": "STRING", "mode": "NULLABLE"},
        {"name": "scheduled_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
        {"name": "cohort", "type": "STRING", "mode": "NULLABLE"}
    ]
    
    # Save the fixed schema
    os.makedirs('config', exist_ok=True)
    schema_file = 'config/schema_taxi_search_history_fixed.json'
    with open(schema_file, 'w') as f:
        json.dump(schema, f, indent=2)
    
    logger.info(f"Created fixed schema at {schema_file}")
    return schema_file

def load_to_bigquery(dataset, table, gcs_uri, schema_file, credentials_file=None):
    """Load data from GCS to BigQuery with fixed schema."""
    # Set credentials if provided
    if credentials_file:
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_file
        
    # Load schema from file
    with open(schema_file, 'r') as f:
        schema = json.load(f)
    
    # Convert schema to BigQuery format
    bq_schema = []
    for field in schema:
        bq_schema.append(bigquery.SchemaField(
            field['name'], field['type'], mode=field['mode']
        ))
    
    # Initialize BigQuery client
    client = bigquery.Client()
    
    # Configure job
    job_config = bigquery.LoadJobConfig(
        schema=bq_schema,
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=0,
        allow_quoted_newlines=True,
        allow_jagged_rows=True,
        null_marker='\\N',
        field_delimiter='\t',  # Use tab delimiter for PostgreSQL COPY format
    )
    
    # Start the load job
    table_ref = f"{dataset}.{table}"
    logger.info(f"Loading data from {gcs_uri} to {table_ref}")
    load_job = client.load_table_from_uri(
        gcs_uri, table_ref, job_config=job_config
    )
    
    # Wait for the job to complete
    load_job.result()
    logger.info(f"Loaded {load_job.output_rows} rows into {table_ref}")

def main():
    """Main function to load taxi_search_history with fixed schema"""
    parser = argparse.ArgumentParser(description='Load taxi_search_history with fixed schema')
    parser.add_argument('--bucket', required=True, help='GCS bucket name')
    parser.add_argument('--dataset', required=True, help='BigQuery dataset ID')
    parser.add_argument('--credentials', help='Path to GCP credentials JSON file')
    args = parser.parse_args()
    
    # Create fixed schema
    schema_file = create_fixed_schema()
    
    # Load taxi_search_history with fixed schema
    try:
        gcs_uri = f"gs://{args.bucket}/taxi_data/taxi_search_history.csv"
        load_to_bigquery(args.dataset, "taxi_search_history", gcs_uri, schema_file, args.credentials)
        logger.info(f"Successfully loaded taxi_search_history to BigQuery")
    except Exception as e:
        logger.error(f"Error loading taxi_search_history: {str(e)}")
        logger.error(f"Error details: {str(getattr(e, 'errors', []))}")
    
    logger.info("Loading complete")

if __name__ == "__main__":
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    main()