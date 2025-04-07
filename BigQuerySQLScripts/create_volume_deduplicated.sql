SELECT date, blockchain, trading_volume
FROM (SELECT date, blockchain, TRADING_VOLUME, row_number() OVER (PARTITION BY date, blockchain ORDER BY EXTRACT_TIME DESC, TRADING_VOLUME DESC) AS r
FROM `chainlink-455803.Prod_1.stg_volume_raw`)
WHERE r = 1
ORDER BY date DESC;