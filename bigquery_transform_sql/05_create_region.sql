CREATE TABLE `obi.region` AS
WITH city_data AS (
  SELECT 
    1 as city_id, 
    'Houston' as city, 
    'IAH' as airport_code, 
    29.9902 as airport_lat, 
    -95.3368 as airport_lng,
    29.7604 as city_center_lat,
    -95.3698 as city_center_lng
  UNION ALL
  SELECT 2, 'Chicago', 'ORD', 41.9786, -87.9048, 41.8781, -87.6298 UNION ALL
  SELECT 3, 'Miami', 'MIA', 25.7932, -80.2906, 25.7617, -80.1918 UNION ALL
  SELECT 4, 'Minneapolis', 'MSP', 44.8848, -93.2223, 44.9778, -93.2650 UNION ALL
  SELECT 5, 'New York City', 'LGA', 40.7769, -73.8740, 40.7128, -74.0060 UNION ALL
  SELECT 5, 'New York City', 'JFK', 40.6413, -73.7781, 40.7128, -74.0060 UNION ALL
  SELECT 5, 'New York City', 'EWR', 40.6895, -74.1745, 40.7128, -74.0060 UNION ALL
  SELECT 6, 'Boston', 'BOS', 42.3656, -71.0096, 42.3601, -71.0589 UNION ALL
  SELECT 7, 'Los Angeles', 'LAX', 33.9416, -118.4085, 34.0522, -118.2437 UNION ALL
  SELECT 8, 'Seattle', 'SEA', 47.4502, -122.3088, 47.6062, -122.3321
)
SELECT * FROM city_data
ORDER BY city_id, airport_code;


INSERT INTO `obi.region` (city_id, city, airport_code, airport_lat, airport_lng, city_center_lat, city_center_lng)
VALUES 
    -- Existing ones from before
    (2, 'Chicago', 'MDW', 41.7868, -87.7522, 41.8781, -87.6298),
    (1, 'Houston', 'HOU', 29.6454, -95.2789, 29.7604, -95.3698),
    (7, 'Los Angeles', 'BUR', 34.2007, -118.3590, 34.0522, -118.2437),
    (7, 'Los Angeles', 'SNA', 33.6762, -117.8675, 34.0522, -118.2437),
    -- Adding Florida airports
    (3, 'Miami', 'FLL', 26.0742, -80.1506, 25.7617, -80.1918),
    (3, 'Miami', 'PBI', 26.6832, -80.0956, 25.7617, -80.1918);

INSERT INTO `obi.region` (city_id, city, airport_code, airport_lat, airport_lng, city_center_lat, city_center_lng)
VALUES 
    -- Boston area airports
    (6, 'Boston', 'MHT', 42.9320, -71.4352, 42.3601, -71.0589),
    (6, 'Boston', 'PVD', 41.7240, -71.4283, 42.3601, -71.0589),
    -- Los Angeles area airports
    (7, 'Los Angeles', 'LGB', 33.8177, -118.1515, 34.0522, -118.2437),
    (7, 'Los Angeles', 'ONT', 34.0558, -117.6011, 34.0522, -118.2437),
    -- Seattle area airport
    (8, 'Seattle', 'PAE', 47.9063, -122.2812, 47.6062, -122.3321);