# scripts/run_pipeline.py
#!/usr/bin/env python3
"""
Wrapper script to run the full extraction and loading pipeline.
"""
import os
import sys
import logging
import argparse
import subprocess

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/pipeline.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

def main():
    """Run the full pipeline"""
    parser = argparse.ArgumentParser(description='Run full extraction and loading pipeline')
    parser.add_argument('--sql_file', required=True, help='Path to the SQL dump file')
    parser.add_argument('--bucket', required=True, help='GCS bucket name')
    parser.add_argument('--dataset', required=True, help='BigQuery dataset ID')
    parser.add_argument('--tables', nargs='+', default=['taxi_search_history', 'taxi_request'], 
                        help='Tables to process (default: taxi_search_history taxi_request)')
    parser.add_argument('--credentials', help='Path to GCP credentials JSON file')
    args = parser.parse_args()
    
    # Step 1: Process SQL dump
    logger.info("Step 1: Processing SQL dump")
    process_cmd = [
        sys.executable, 'scripts/process_sql_dump.py',
        '--sql_file', args.sql_file,
        '--tables'
    ] + args.tables
    
    process_result = subprocess.run(process_cmd)
    if process_result.returncode != 0:
        logger.error("SQL processing failed. Exiting.")
        return
    
    # Step 2: Load to BigQuery
    logger.info("Step 2: Loading to BigQuery")
    load_cmd = [
        sys.executable, 'scripts/load_to_bigquery.py',
        '--bucket', args.bucket,
        '--dataset', args.dataset,
        '--tables'
    ] + args.tables
    
    if args.credentials:
        load_cmd.extend(['--credentials', args.credentials])
    
    load_result = subprocess.run(load_cmd)
    if load_result.returncode != 0:
        logger.error("BigQuery loading failed. Exiting.")
        return
    
    logger.info("Pipeline completed successfully")

if __name__ == "__main__":
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    main()