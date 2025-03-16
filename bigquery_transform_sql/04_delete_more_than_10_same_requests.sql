-- Create a temporary table with row numbers for each group
CREATE OR REPLACE TEMP TABLE rows_to_keep AS
SELECT 
    search_id,
    ROW_NUMBER() OVER (
        PARTITION BY user_id, pickup_address, destination_address, DATE(requested_at)
        ORDER BY requested_at  
    ) as row_num,
    COUNT(*) OVER (
        PARTITION BY user_id, pickup_address, destination_address, DATE(requested_at)
    ) as group_count
FROM `obi.taxi_search_history_us_8_standard`
WHERE pickup_address IS NOT NULL 
    AND destination_address IS NOT NULL
    AND product_name = 'UberX';

-- Delete all rows except the first 5 rows of each group that has more than 5 rows
DELETE FROM `obi.taxi_search_history_us_8_standard` 
WHERE search_id IN (
    SELECT search_id 
    FROM rows_to_keep
    WHERE row_num > 5  -- Keep only first 5 rows
    AND group_count > 5  -- Only in groups with more than 5 rows
);