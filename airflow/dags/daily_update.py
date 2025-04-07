from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from datetime import datetime
import json
import requests
import pandas as pd
import time
from google.cloud import bigquery
import os
import logging

log = logging.getLogger('Web3-Market-Metrics-Daily-Update')
#
# Configure logging
#
logging.basicConfig(
    level = logging.INFO,
    format = "%(asctime)s.%(msecs)03d|%(name)-20s|%(levelname)-8s|%(message)s", 
    datefmt = "%Y-%m-%d %H:%M:%S")

#
# Configure BigQuery credentials and other details
#
credentials_path = '/etc/bigquery_creds.json'
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
chains = ['ethereum', 'bitcoin', 'solana', 'cardano', 'ripple']
current_timestamp = datetime.now()
client = bigquery.Client()

#
# Update TVL data
#
def update_tvl():

    #
    # Pull data from DefiLlama
    #
    log.info('Pulling TVL data from DefiLlama')
    url = 'https://api.llama.fi/v2/chains'
    response = requests.get(url)

    if response.status_code == 200:
        log.info('Successfully pulled TVL data from DefiLlama')
    else:
        log.error('Failed to pull TVL data from DefiLlama')
        return 1
    
    tvl_formatted_json_response = []
    for row in response.json():
        if row['gecko_id'] in chains:
            chain = row['gecko_id'].upper()
            new_row = {}
            new_row['EXTRACT_TIME'] = current_timestamp.strftime("%Y-%m-%d %H:%M:%S")
            new_row['BLOCKCHAIN'] = chain
            new_row['DATE'] = current_timestamp.strftime("%Y-%m-%d")
            new_row['TVL'] = int(row['tvl'])
            tvl_formatted_json_response += [new_row]

    #
    # Load data into BigQuery
    #
    log.info('Loading TVL data into BigQuery')
    tvl_table_id = 'chainlink-455803.Prod_1.stg_tvl_raw'
    errors = client.insert_rows_json(tvl_table_id, tvl_formatted_json_response)

    if errors:
        log.error('Failed to upload TVL data to BigQuery')
        return 2
    
    log.info('Successfully loaded TVL data into BigQuery')
    return 0


def update_stablecoin_marketcap():

    #
    # Pull data from DefiLlama
    #
    log.info('Pulling stablecoin market cap data from DefiLlama')
    url = 'https://stablecoins.llama.fi/stablecoinchains'
    response = requests.get(url)

    if response.status_code == 200:
        log.info('Successfully pulled stablecoin market cap data from DefiLlama')
    else:
        log.error('Failed to pull stablecoin market cap data from DefiLlama')
        return 1
    
    stablecoin_marketcap_formatted_json_response = []
    for row in response.json():
        if row['gecko_id'] in chains:
            chain = row['gecko_id'].upper()
            new_row = {}
            new_row['EXTRACT_TIME'] = current_timestamp.strftime("%Y-%m-%d %H:%M:%S")
            new_row['BLOCKCHAIN'] = chain
            new_row['DATE'] = current_timestamp.strftime("%Y-%m-%d")
            new_row['STABLECOIN_MARKETCAP'] = int(row['totalCirculatingUSD']['peggedUSD'])
            stablecoin_marketcap_formatted_json_response += [new_row]
    
    #
    # Load data into BigQuery
    #
    log.info('Loading stablecoin market cap data into BigQuery')
    stablecoin_marketcap_table_id = 'chainlink-455803.Prod_1.stg_stablecoin_marketcap_raw'
    errors = client.insert_rows_json(stablecoin_marketcap_table_id, stablecoin_marketcap_formatted_json_response)
    
    if errors:
        log.error('Failed to upload stablecoin market cap data to BigQuery')
        return 2
    
    log.info('Successfully loaded stablecoin market cap data into BigQuery')
    return 0





def update_marketcap_volume():

    #
    # Pull data from CoinGecko
    #
    log.info('Pulling market cap and volume data from CoinGecko')
    marketcap_formatted_json_response = []
    volume_formatted_json_response = []
    currency = 'usd'
    cg_api_key = 'CG-i5kd5dR33FYgvAr5jV2frxZG'
    for chain in chains:
        time.sleep(10) # To avoid rate limit
        url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency={currency}&ids={chain}".format(currency=currency,chain=chain)
        headers = {"accept": "application/json", "x-cg-pro-api-key": cg_api_key}
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            log.info('Successfully pulled market cap and volume data from CoinGecko for ' + chain)
        else:
            log.error('Failed to pull market cap and volume data from CoinGecko for ' + chain)
            return 1

        row = response.json()[0]
        new_row = {}
        new_row['EXTRACT_TIME'] = current_timestamp.strftime("%Y-%m-%d %H:%M:%S")
        new_row['BLOCKCHAIN'] = chain.upper()
        new_row['DATE'] = current_timestamp.strftime("%Y-%m-%d")
        new_row['TOTAL_MARKETCAP'] = int(row['market_cap'])
        marketcap_formatted_json_response += [new_row]

        new_row = {}
        new_row['EXTRACT_TIME'] = current_timestamp.strftime("%Y-%m-%d %H:%M:%S")
        new_row['BLOCKCHAIN'] = chain.upper()
        new_row['DATE'] = current_timestamp.strftime("%Y-%m-%d")
        new_row['TRADING_VOLUME'] = int(row['total_volume'])
        volume_formatted_json_response += [new_row]

    #
    # Load data into BigQuery
    #
    log.info('Loading market cap data into BigQuery')
    marketcap_table_id = 'chainlink-455803.Prod_1.stg_marketcap_raw'
    errors = client.insert_rows_json(marketcap_table_id, marketcap_formatted_json_response)
    if errors:
        log.error('Failed to upload market cap data to BigQuery')
        return 2

    log.info('Loading volume data into BigQuery')
    volume_table_id = 'chainlink-455803.Prod_1.stg_volume_raw'
    errors = client.insert_rows_json(volume_table_id, volume_formatted_json_response)
    if errors:
        log.error('Failed to upload volume data to BigQuery')
        return 2
    
    log.info('Successfully loaded  market cap and volume data into BigQuery')
    return 0


dag = DAG(

    'daily_update',

    default_args={'start_date': days_ago(1)},

    schedule_interval='0 6 * * *',

    catchup=False

)



update_tvl_task = PythonOperator(

    task_id='update_tvl',

    python_callable=update_tvl,

    dag=dag

)



update_stablecoin_marketcap_task = PythonOperator(

    task_id='update_stablecoin_marketcap',

    python_callable=update_stablecoin_marketcap,

    dag=dag

)



update_marketcap_volume_task = PythonOperator(

    task_id='update_marketcap_volume',

    python_callable=update_marketcap_volume,

    dag=dag

)

update_marketcap_volume_task >> update_tvl_task >> update_stablecoin_marketcap_task