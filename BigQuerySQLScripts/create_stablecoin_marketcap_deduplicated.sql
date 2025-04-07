SELECT date, blockchain, stablecoin_marketcap
FROM (SELECT date, blockchain, STABLECOIN_MARKETCAP, row_number() OVER (PARTITION BY date, blockchain ORDER BY EXTRACT_TIME DESC) AS r
FROM `chainlink-455803.Prod_1.stg_stablecoin_marketcap_raw`)
WHERE r = 1
ORDER BY date DESC;