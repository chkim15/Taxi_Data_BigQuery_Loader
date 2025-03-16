-- First add the new column (without default value)
ALTER TABLE `obi.taxi_search_history_us`
ADD COLUMN IF NOT EXISTS is_null_region BOOLEAN;

-- Then set default value for the column 
ALTER TABLE `obi.taxi_search_history_us`
ALTER COLUMN is_null_region SET DEFAULT false;

-- Initialize existing rows with the default value
UPDATE `obi.taxi_search_history_us`
SET is_null_region = false
WHERE is_null_region IS NULL;

-- Boston
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Boston',
    is_null_region = true
WHERE region IS NULL
    AND REGEXP_CONTAINS(pickup_address, r'Boston')
    AND pickup_lat BETWEEN 41.8 AND 42.7
    AND pickup_lng BETWEEN -71.5 AND -70.5;

-- New York City
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'New York City',
    is_null_region = true
WHERE region IS NULL
    AND (REGEXP_CONTAINS(pickup_address, r'New York') OR REGEXP_CONTAINS(pickup_address, r'Bronx') OR 
         REGEXP_CONTAINS(pickup_address, r'Brooklyn') OR REGEXP_CONTAINS(pickup_address, r'Queens'))
    AND pickup_lat BETWEEN 40.4 AND 41.0
    AND pickup_lng BETWEEN -74.3 AND -73.6;

-- Chicago
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Chicago',
    is_null_region = true
WHERE region IS NULL
    AND REGEXP_CONTAINS(pickup_address, r'Chicago')
    AND pickup_lat BETWEEN 41.6 AND 42.1
    AND pickup_lng BETWEEN -88.0 AND -87.3;

-- Los Angeles
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Los Angeles',
    is_null_region = true
WHERE region IS NULL
    AND REGEXP_CONTAINS(pickup_address, r'Los Angeles')
    AND pickup_lat BETWEEN 33.7 AND 34.4
    AND pickup_lng BETWEEN -118.7 AND -118.0;

-- Miami
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Miami',
    is_null_region = true
WHERE region IS NULL
    AND REGEXP_CONTAINS(pickup_address, r'Miami')
    AND pickup_lat BETWEEN 25.5 AND 26.0
    AND pickup_lng BETWEEN -80.5 AND -80.0;

-- Seattle
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Seattle',
    is_null_region = true
WHERE region IS NULL
    AND REGEXP_CONTAINS(pickup_address, r'Seattle')
    AND pickup_lat BETWEEN 47.4 AND 47.8
    AND pickup_lng BETWEEN -122.5 AND -122.1;

-- Minneapolis
UPDATE `obi.taxi_search_history_us`
SET region = 'Minneapolis'
WHERE region IN ('Minneapolis - St. Paul', 'Minneapolis-St. Paul');

UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Minneapolis',
    is_null_region = true
WHERE region IS NULL
    AND (REGEXP_CONTAINS(pickup_address, r'Minneapolis') OR REGEXP_CONTAINS(pickup_address, r'St\. Paul'))
    AND pickup_lat BETWEEN 44.8 AND 45.1
    AND pickup_lng BETWEEN -93.4 AND -92.8;

-- Houston
UPDATE `obi.taxi_search_history_us`
SET 
    region = 'Houston',
    is_null_region = true
WHERE region IS NULL
    AND REGEXP_CONTAINS(pickup_address, r'Houston')
    AND pickup_lat BETWEEN 29.4 AND 30.1
    AND pickup_lng BETWEEN -95.8 AND -95.0;

CREATE OR REPLACE TABLE `obi.taxi_search_history_us_8` AS
SELECT *
FROM `obi.taxi_search_history_us`
WHERE region IN (
  'Boston',
  'New York City',
  'Chicago',
  'Los Angeles',
  'Miami',
  'Seattle',
  'Minneapolis',
  'Houston'
);