CREATE OR REPLACE TABLE `obi.taxi_search_history_us_8_standard` AS (
    WITH search_both_products AS (
        SELECT 
            search_id
        FROM `obi.taxi_search_history_us_8`
        WHERE 
            search_id IS NOT NULL
            AND product_name IN ('UberX', 'Lyft')
        GROUP BY search_id
        HAVING COUNT(DISTINCT product_name) = 2
    )
    SELECT 
        e.*,
    CASE 
        WHEN t.service_type = 'TAXI_RESERVATION_DEEPLINK' THEN TRUE 
        ELSE FALSE 
    END as quote_selected
    FROM `obi.taxi_search_history_us_8` e
    LEFT JOIN `obi.taxi_request` t 
      ON e.search_id = t.search_id
    WHERE 
        e.search_id IN (SELECT search_id FROM search_both_products)
        AND e.product_name IN ('UberX', 'Lyft', 'Curb Taxi', 'Carmel Full Size Sedan')
        AND distance_meters > 482.8  -- 0.3 miles in meters
        AND distance_meters < 80467.2  -- 50 miles in meters
        AND price_min < 200
        AND price_min IS NOT NULL
        AND duration_seconds < 10800  -- 3 hours in seconds
);
