# scripts/utils/sql_parser.py
import re
import os
import csv
from tqdm import tqdm

def find_table_copy_section(sql_file, table_name):
    """
    Find the COPY section for a specific table in a PostgreSQL dump file.
    Returns the start position and end marker.
    """
    copy_start_pattern = f"COPY public.{table_name} .* FROM stdin;"
    with open(sql_file, 'r', encoding='utf-8') as f:
        print(f"Searching for {table_name} COPY section...")
        line_num = 0
        for line in f:
            line_num += 1
            if re.match(copy_start_pattern, line):
                print(f"Found COPY section at line {line_num}")
                return line_num
    return None

def extract_table_data(sql_file, table_name, output_file, batch_size=100000):
    """
    Extract data for a specific table from a PostgreSQL SQL dump file.
    
    Args:
        sql_file (str): Path to the SQL dump file
        table_name (str): Name of the table to extract
        output_file (str): Path to save the extracted data (CSV)
        batch_size (int): Number of rows to process before writing to disk
    
    Returns:
        int: Number of rows extracted
    """
    copy_line_num = find_table_copy_section(sql_file, table_name)
    if copy_line_num is None:
        raise ValueError(f"Could not find COPY section for table {table_name}")
    
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    # Process the data in batches
    row_count = 0
    batch_count = 0
    batch = []
    
    # Skip to the COPY section
    with open(sql_file, 'r', encoding='utf-8') as f:
        # Skip to the COPY line
        for _ in range(copy_line_num):
            next(f)
        
        print(f"Starting extraction for {table_name}...")
        with open(output_file, 'w', newline='', encoding='utf-8') as out_file:
            writer = csv.writer(out_file)
            
            # Process data rows until we reach end marker '\.'
            for line in tqdm(f, desc=f"Extracting {table_name}"):
                if line.strip() == '\.':
                    # End of the COPY section
                    if batch:
                        writer.writerows(batch)
                    print(f"Extraction complete. Processed {row_count} rows.")
                    return row_count
                
                # Split the line using PostgreSQL's tab delimiter and handle nulls
                row = []
                for val in line.rstrip('\n').split('\t'):
                    if val == '\\N':
                        row.append(None)  # Convert PostgreSQL NULL to Python None
                    else:
                        row.append(val)
                
                batch.append(row)
                row_count += 1
                
                # Write batch to file if batch_size reached
                if len(batch) >= batch_size:
                    writer.writerows(batch)
                    batch = []
                    batch_count += 1
                    print(f"Wrote batch {batch_count} ({batch_size} rows)")
    
    return row_count