# scripts/process_sql_dump.py
#!/usr/bin/env python3
"""
Script to process a PostgreSQL SQL dump and extract tables for BigQuery loading.
"""
import os
import sys
import logging
import argparse
from utils.sql_parser import extract_table_data

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/processing.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

def main():
    """Main processing function"""
    parser = argparse.ArgumentParser(description='Process PostgreSQL dump and extract tables')
    parser.add_argument('--sql_file', required=True, help='Path to the SQL dump file')
    parser.add_argument('--tables', nargs='+', default=['taxi_search_history', 'taxi_request'], 
                        help='Tables to extract (default: taxi_search_history taxi_request)')
    args = parser.parse_args()
    
    # Create output directory (include the "processed" subdirectory)
    os.makedirs('/Volumes/Elements/data/processed', exist_ok=True)
    
    # Extract each table
    for table in args.tables:
        logger.info(f"Processing table: {table}")
        try:
            output_file = f"/Volumes/Elements/data/processed/{table}.csv"
            rows = extract_table_data(args.sql_file, table, output_file)
            logger.info(f"Extracted {rows} rows from {table} to {output_file}")
        except Exception as e:
            logger.error(f"Error processing table {table}: {str(e)}")
    
    logger.info("Processing complete")

if __name__ == "__main__":
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    main()