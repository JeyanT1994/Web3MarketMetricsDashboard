WITH bitcoin AS (
  SELECT date, STABLECOIN_MARKETCAP
  FROM `chainlink-455803.Prod_1.stablecoin_marketcap_deduplicated`
  WHERE blockchain = 'BITCOIN'
),
ethereum AS (
  SELECT date, stablecoin_marketcap
  FROM `chainlink-455803.Prod_1.stablecoin_marketcap_deduplicated`
  WHERE blockchain = 'ETHEREUM'
),
solana AS (
  SELECT date, stablecoin_marketcap
  FROM `chainlink-455803.Prod_1.stablecoin_marketcap_deduplicated`
  WHERE blockchain = 'SOLANA'
),
cardano AS (
  SELECT date, stablecoin_marketcap
  FROM `chainlink-455803.Prod_1.stablecoin_marketcap_deduplicated`
  WHERE blockchain = 'CARDANO'
),
ripple AS (
  SELECT date, stablecoin_marketcap
  FROM `chainlink-455803.Prod_1.stablecoin_marketcap_deduplicated`
  WHERE blockchain = 'RIPPLE'
)
SELECT coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) AS date, 
bitcoin.stablecoin_marketcap AS total_bitcoin_stablecoin_marketcap,
ethereum.stablecoin_marketcap AS total_ethereum_stablecoin_marketcap,
solana.stablecoin_marketcap AS total_solana_stablecoin_marketcap,
cardano.stablecoin_marketcap AS total_cardano_stablecoin_marketcap,
ripple.stablecoin_marketcap AS total_ripple_stablecoin_marketcap,
coalesce(bitcoin.stablecoin_marketcap,0) + coalesce(ethereum.stablecoin_marketcap,0) + coalesce(solana.stablecoin_marketcap,0) + coalesce(cardano.stablecoin_marketcap,0) + coalesce(ripple.stablecoin_marketcap,0) AS total_combined_stablecoin_marketcap
FROM bitcoin
FULL OUTER JOIN ethereum ON bitcoin.date = ethereum.date
FULL OUTER JOIN solana ON ethereum.date = solana.date
FULL OUTER JOIN cardano ON ethereum.date = cardano.date
FULL OUTER JOIN ripple ON ethereum.date = ripple.date
WHERE coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY)
AND EXTRACT(day FROM coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date)) = 1
ORDER BY coalesce(bitcoin.date, ethereum.date, solana.date, cardano.date, ripple.date) DESC;


