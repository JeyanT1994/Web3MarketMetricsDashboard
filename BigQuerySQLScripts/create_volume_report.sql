WITH bitcoin AS (
  SELECT date, TRADING_VOLUME
  FROM `chainlink-455803.Prod_1.volume_deduplicated`
  WHERE blockchain = 'BITCOIN'
),
ethereum AS (
  SELECT date, trading_volume
  FROM `chainlink-455803.Prod_1.volume_deduplicated`
  WHERE blockchain = 'ETHEREUM'
),
solana AS (
  SELECT date, trading_volume
  FROM `chainlink-455803.Prod_1.volume_deduplicated`
  WHERE blockchain = 'SOLANA'
),
cardano AS (
  SELECT date, trading_volume
  FROM `chainlink-455803.Prod_1.volume_deduplicated`
  WHERE blockchain = 'CARDANO'
),
ripple AS (
  SELECT date, trading_volume
  FROM `chainlink-455803.Prod_1.volume_deduplicated`
  WHERE blockchain = 'RIPPLE'
)
SELECT coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) AS date, 
bitcoin.trading_volume AS total_bitcoin_volume,
ethereum.trading_volume AS total_ethereum_volume,
solana.trading_volume AS total_solana_volume,
cardano.trading_volume AS total_cardano_volume,
ripple.trading_volume AS total_ripple_volume,
coalesce(bitcoin.trading_volume,0) + coalesce(ethereum.trading_volume,0) + coalesce(solana.trading_volume,0) + coalesce(cardano.trading_volume,0) + coalesce(ripple.trading_volume,0) AS total_combined_volume
FROM bitcoin
FULL OUTER JOIN ethereum ON bitcoin.date = ethereum.date
FULL OUTER JOIN solana ON ethereum.date = solana.date
FULL OUTER JOIN cardano ON ethereum.date = cardano.date
FULL OUTER JOIN ripple ON ethereum.date = ripple.date
WHERE coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY)
AND EXTRACT(day FROM coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date)) = 1
ORDER BY coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) DESC;


