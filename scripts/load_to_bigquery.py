# scripts/load_to_bigquery.py
#!/usr/bin/env python3
"""
Script to load processed data into BigQuery.
"""
import os
import sys
import json
import logging
import argparse
from google.cloud import bigquery
from google.cloud import storage

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/bigquery_loading.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

def upload_to_gcs(bucket_name, source_file, destination_blob, credentials_file=None):
    """Upload a file to Google Cloud Storage."""
    if credentials_file:
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_file
    
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob)
    
    logger.info(f"Uploading {source_file} to gs://{bucket_name}/{destination_blob}")
    blob.upload_from_filename(source_file)
    logger.info(f"File {source_file} uploaded to gs://{bucket_name}/{destination_blob}")

def load_to_bigquery(dataset, table, gcs_uri, schema_file, credentials_file=None):
    """Load data from GCS to BigQuery."""
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
        null_marker='',
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
    """Main BigQuery loading function"""
    parser = argparse.ArgumentParser(description='Load data into BigQuery')
    parser.add_argument('--bucket', required=True, help='GCS bucket name')
    parser.add_argument('--dataset', required=True, help='BigQuery dataset ID')
    parser.add_argument('--tables', nargs='+', default=['taxi_search_history', 'taxi_request'], 
                        help='Tables to load (default: taxi_search_history taxi_request)')
    parser.add_argument('--credentials', help='Path to GCP credentials JSON file')
    args = parser.parse_args()
    
    for table in args.tables:
        try:
            # 1. Upload to GCS
            source_file = f"/Volumes/Elements/data/processed/{table}.csv"
            destination_blob = f"taxi_data/{table}.csv"
            upload_to_gcs(args.bucket, source_file, destination_blob, args.credentials)
            
            # 2. Load to BigQuery
            gcs_uri = f"gs://{args.bucket}/{destination_blob}"
            schema_file = f"config/schema_{table}.json"
            load_to_bigquery(args.dataset, table, gcs_uri, schema_file, args.credentials)
            
            logger.info(f"Successfully loaded {table} to BigQuery")
        except Exception as e:
            logger.error(f"Error loading table {table}: {str(e)}")
    
    logger.info("Loading complete")

if __name__ == "__main__":
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    main()