WITH bitcoin AS (
  SELECT date, total_marketcap
  FROM `chainlink-455803.Prod_1.marketcap_deduplicated`
  WHERE blockchain = 'BITCOIN'
),
ethereum AS (
  SELECT date, total_marketcap
  FROM `chainlink-455803.Prod_1.marketcap_deduplicated`
  WHERE blockchain = 'ETHEREUM'
),
solana AS (
  SELECT date, total_marketcap
  FROM `chainlink-455803.Prod_1.marketcap_deduplicated`
  WHERE blockchain = 'SOLANA'
),
cardano AS (
  SELECT date, total_marketcap
  FROM `chainlink-455803.Prod_1.marketcap_deduplicated`
  WHERE blockchain = 'CARDANO'
),
ripple AS (
  SELECT date, total_marketcap
  FROM `chainlink-455803.Prod_1.marketcap_deduplicated`
  WHERE blockchain = 'RIPPLE'
)
SELECT coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) AS date, 
bitcoin.total_marketcap AS total_bitcoin_marketcap,
ethereum.total_marketcap AS total_ethereum_marketcap,
solana.total_marketcap AS total_solana_marketcap,
cardano.total_marketcap AS total_cardano_marketcap,
ripple.total_marketcap AS total_ripple_marketcap,
coalesce(bitcoin.total_marketcap,0) + coalesce(ethereum.total_marketcap,0) + coalesce(solana.total_marketcap,0) + coalesce(cardano.total_marketcap,0) + coalesce(ripple.total_marketcap,0) AS total_combined_marketcap
FROM bitcoin
FULL OUTER JOIN ethereum ON bitcoin.date = ethereum.date
FULL OUTER JOIN solana ON bitcoin.date = solana.date
FULL OUTER JOIN cardano ON bitcoin.date = cardano.date
FULL OUTER JOIN ripple ON bitcoin.date = ripple.date
WHERE coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY)
AND EXTRACT(day FROM coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date)) = 1
ORDER BY coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) DESC;


