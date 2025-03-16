CREATE OR REPLACE TABLE `obi.taxi_search_history_us` AS
SELECT *
FROM `obi.taxi_search_history`
WHERE pickup_lat BETWEEN 24.396308 AND 49.384358
  AND pickup_lng BETWEEN -125.000000 AND -66.934570
  AND NOT REGEXP_CONTAINS(user_id, r'ml')
  AND user_id NOT IN (
    'd0TNEGMbA8U8inch',
    'llUB79vCvszbCHXb',
    'EDoGXc64RVGVGenl-competitor',
    'XywjvwSLNG24gzVW-competitor', 
    'djxOK6dAOec6VoFq',
    '0yIEYwubahEljVJB-TAXIFY',
    'TC6SlabYWNaCUgVV-digitalocean-validator',
    'EDoGXc64RVGVGenl',
    'NbWm8ktWFNebfXoi-UBER',
    'DvZecisTiZ0kYyOt',
    'Lr9wSWgvpTtOPhhw-uber-web',
    '0yIEYwubahEljVJB-LYFT-competitor',
    'VTmSqS4N4VMO3u8Q',
    'NbWm8ktWFNebfXoi-BOLT',
    '0yIEYwubahEljVJB-OLA',
    '0yIEYwubahEljVJB-CABIFY',
    '0yIEYwubahEljVJB-UBER-competitor',
    '0yIEYwubahEljVJB-BOLT',
    '0yIEYwubahEljVJB-FREENOW',
    '0yIEYwubahEljVJB-LYFT',
    'pOnxwMsyXsuuilA3',
    'NbWm8ktWFNebfXoi-FREENOW',
    'Oi6q8kZ7dDuyC9Fj-Bolt',
    'XywjvwSLNG24gzVW',
    'SimN6p6yK5l5l1Y5',
    'iiZ29YXaWwVEQhxm',
    '4FWfjdqoEMgc06VA',
    '5JtW8uNVjHiCtR8O-UBER',
    'xXDNbjDxxFAg8b3n',
    'KqpKPSB8gJPaoDaY',
    'wkXnGWG1ysZCrURE',
    'Oi6q8kZ7dDuyC9Fj',
    '0yIEYwubahEljVJB-UBER'
  );