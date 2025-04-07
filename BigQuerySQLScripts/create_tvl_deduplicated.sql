SELECT date, blockchain, tvl
FROM (SELECT date, blockchain, tvl, row_number() OVER (PARTITION BY date, blockchain ORDER BY EXTRACT_TIME DESC) AS r
FROM `chainlink-455803.Prod_1.stg_tvl_raw`)
WHERE r = 1
ORDER BY date DESC;