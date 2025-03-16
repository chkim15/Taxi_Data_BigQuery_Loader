ALTER TABLE `obi.taxi_search_history_us_8_standard`
ADD COLUMN IF NOT EXISTS pickup_place_category STRING,
ADD COLUMN IF NOT EXISTS destination_place_category STRING;

UPDATE `obi.taxi_search_history_us_8_standard` e
SET 
  pickup_place_category = (
    CASE 
      WHEN EXISTS (
        SELECT 1 
        FROM `obi.region` r
        WHERE ST_DISTANCE(
          ST_GEOGPOINT(e.pickup_lng, e.pickup_lat),
          ST_GEOGPOINT(r.airport_lng, r.airport_lat)
        ) <= 1609.34  -- 1 mile in meters
      ) OR LOWER(pickup_address) LIKE '%airport%'
      THEN 'airport'
      WHEN EXISTS (
        SELECT 1 
        FROM `obi.region` r
        WHERE ST_DISTANCE(
          ST_GEOGPOINT(e.pickup_lng, e.pickup_lat),
          ST_GEOGPOINT(r.city_center_lng, r.city_center_lat)
        ) <= CASE 
               WHEN e.region IN ('Houston', 'Los Angeles', 'Miami', 'Minneapolis') THEN 8046.72  -- 5 miles in meters
               ELSE 4828.032  -- 3 miles in meters
             END
      ) THEN 'city center'
      ELSE 'outside city center'
    END),
  destination_place_category = (
    CASE 
      WHEN EXISTS (
        SELECT 1 
        FROM `obi.region` r
        WHERE ST_DISTANCE(
          ST_GEOGPOINT(e.destination_lng, e.destination_lat),
          ST_GEOGPOINT(r.airport_lng, r.airport_lat)
        ) <= 1609.34  -- 1 mile in meters
      ) OR LOWER(destination_address) LIKE '%airport%'
      THEN 'airport'
      WHEN EXISTS (
        SELECT 1 
        FROM `obi.region` r
        WHERE ST_DISTANCE(
          ST_GEOGPOINT(e.destination_lng, e.destination_lat),
          ST_GEOGPOINT(r.city_center_lng, r.city_center_lat)
        ) <= CASE 
               WHEN e.region IN ('Houston', 'Los Angeles', 'Miami', 'Minneapolis') THEN 8046.72  -- 5 miles in meters
               ELSE 4828.032  -- 3 miles in meters
             END
      ) THEN 'city center'
      ELSE 'outside city center'
    END)
WHERE TRUE;