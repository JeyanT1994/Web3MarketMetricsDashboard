WITH bitcoin AS (
  SELECT date, tvl
  FROM `chainlink-455803.Prod_1.tvl_deduplicated`
  WHERE blockchain = 'BITCOIN'
),
ethereum AS (
  SELECT date, tvl
  FROM `chainlink-455803.Prod_1.tvl_deduplicated`
  WHERE blockchain = 'ETHEREUM'
),
solana AS (
  SELECT date, tvl
  FROM `chainlink-455803.Prod_1.tvl_deduplicated`
  WHERE blockchain = 'SOLANA'
),
cardano AS (
  SELECT date, tvl
  FROM `chainlink-455803.Prod_1.tvl_deduplicated`
  WHERE blockchain = 'CARDANO'
),
ripple AS (
  SELECT date, tvl
  FROM `chainlink-455803.Prod_1.tvl_deduplicated`
  WHERE blockchain = 'RIPPLE'
)
SELECT coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) AS date, 
bitcoin.tvl AS total_bitcoin_tvl,
ethereum.tvl AS total_ethereum_tvl,
solana.tvl AS total_solana_tvl,
cardano.tvl AS total_cardano_tvl,
ripple.tvl AS total_ripple_tvl,
coalesce(bitcoin.tvl,0) + coalesce(ethereum.tvl,0) + coalesce(solana.tvl,0) + coalesce(cardano.tvl,0) + coalesce(ripple.tvl,0) AS total_combined_tvl
FROM bitcoin
FULL OUTER JOIN ethereum ON bitcoin.date = ethereum.date
FULL OUTER JOIN solana ON bitcoin.date = solana.date
FULL OUTER JOIN cardano ON bitcoin.date = cardano.date
FULL OUTER JOIN ripple ON bitcoin.date = ripple.date
WHERE coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY)
AND EXTRACT(day FROM coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date)) = 1
ORDER BY coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) DESC;


