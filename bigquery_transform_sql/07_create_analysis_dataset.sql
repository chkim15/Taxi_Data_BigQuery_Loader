CREATE TABLE `obi.taxi_search_history_us_8_standard_analysis` AS (
    SELECT 
        search_id,
        user_id,
        region,
        product_name,
        requested_at AS requested_at_utc,
        TIMESTAMP(DATETIME(requested_at,
            CASE region
                WHEN 'New York City' THEN 'America/New_York'
                WHEN 'Boston' THEN 'America/New_York'
                WHEN 'Miami' THEN 'America/New_York'
                WHEN 'Chicago' THEN 'America/Chicago'
                WHEN 'Minneapolis' THEN 'America/Chicago'
                WHEN 'Houston' THEN 'America/Chicago'
                WHEN 'Los Angeles' THEN 'America/Los_Angeles'
                WHEN 'Seattle' THEN 'America/Los_Angeles'
            END)) AS local_requested_at,
        FORMAT_DATETIME('%A', DATETIME(requested_at, 
            CASE region
                WHEN 'New York City' THEN 'America/New_York'
                WHEN 'Boston' THEN 'America/New_York'
                WHEN 'Miami' THEN 'America/New_York'
                WHEN 'Chicago' THEN 'America/Chicago'
                WHEN 'Minneapolis' THEN 'America/Chicago'
                WHEN 'Houston' THEN 'America/Chicago'
                WHEN 'Los Angeles' THEN 'America/Los_Angeles'
                WHEN 'Seattle' THEN 'America/Los_Angeles'
            END)) AS day_of_week,
        EXTRACT(HOUR FROM DATETIME(requested_at, 
            CASE region
                WHEN 'New York City' THEN 'America/New_York'
                WHEN 'Boston' THEN 'America/New_York'
                WHEN 'Miami' THEN 'America/New_York'
                WHEN 'Chicago' THEN 'America/Chicago'
                WHEN 'Minneapolis' THEN 'America/Chicago'
                WHEN 'Houston' THEN 'America/Chicago'
                WHEN 'Los Angeles' THEN 'America/Los_Angeles'
                WHEN 'Seattle' THEN 'America/Los_Angeles'
            END)) AS hour_of_day,
        CASE WHEN price_min_discounted IS NULL THEN price_min ELSE price_min_discounted END as price,
        price_min,
        price_min_discounted,
        ROUND(CASE 
            WHEN price_min_discounted IS NOT NULL 
            THEN ((price_min - price_min_discounted) / price_min) * 100 
            ELSE 0 
        END, 2) as discount_rate,
        surge_multiplier,
        distance_meters,
        eta_seconds,
        duration_seconds,
        pickup_place_category,
        destination_place_category,
        pickup_address,
        pickup_lat,
        pickup_lng,
        destination_address,
        destination_lat,
        destination_lng,
        quote_selected 
    FROM `obi.taxi_search_history_us_8_standard` 
    WHERE product_name IN ('UberX', 'Lyft')
);