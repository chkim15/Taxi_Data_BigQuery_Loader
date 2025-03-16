-- For comparative analysis of price between UberX and Lyft (puts price side-by-side)
CREATE TABLE `obi.taxi_search_history_us_8_standard_analysis_2` AS (
    SELECT 
            search_id,
            user_id,
            region,
            MAX(requested_at_utc) AS requested_at_utc,
            MAX(local_requested_at) AS local_requested_at,
            FORMAT_DATETIME('%A', MAX(local_requested_at)) AS day_of_week,
            EXTRACT(HOUR FROM MAX(local_requested_at)) AS hour_of_day,
            MAX(CASE WHEN product_name = 'UberX' AND price_min_discounted IS NULL THEN price_min ELSE price_min_discounted END) as      uberx_price,
            MAX(CASE WHEN product_name = 'Lyft' AND price_min_discounted IS NULL THEN price_min ELSE price_min_discounted END) as       lyft_price,
            ROUND(MAX(CASE 
                WHEN product_name = 'UberX' AND price_min_discounted IS NOT NULL 
                THEN ((price_min - price_min_discounted) / price_min) * 100 
                ELSE 0 
            END), 2) as uberx_discount_rate,
            ROUND(MAX(CASE 
                WHEN product_name = 'Lyft' AND price_min_discounted IS NOT NULL 
                THEN ((price_min - price_min_discounted) / price_min) * 100 
                ELSE 0 
            END), 2) as lyft_discount_rate,
            AVG(distance_meters) AS distance_meters,
            MAX(pickup_place_category) AS pickup_place_category,
            MAX(destination_place_category) AS destination_place_category,
            MAX(pickup_address) AS pickup_address,
            MAX(pickup_lat) AS pickup_lat,
            MAX(pickup_lng) AS pickup_lng,
            MAX(destination_address) AS destination_address,
            MAX(destination_lat) AS destination_lat,
            MAX(destination_lng) AS destination_lng,
            MAX(CASE WHEN product_name = 'UberX' AND quote_selected = TRUE THEN TRUE ELSE FALSE END) AS uberx_selected,
            MAX(CASE WHEN product_name = 'Lyft' AND quote_selected = TRUE THEN TRUE ELSE FALSE END) AS lyft_selected
        FROM `obi.taxi_search_history_us_8_standard_analysis`
        GROUP BY search_id, user_id, region
)