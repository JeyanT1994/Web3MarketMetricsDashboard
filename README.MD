There are three main parts to this submission:
    1 The script that is used to upload historical data to BigQuery
    2 The SQL scripts used in BigQuery to create reporting/loading views
    3 The Airflow DAG that is scheduled to run daily to update the data in BigQuery

The script that is used to upload historical data to BigQuery is the 'HistoricalDataUpload.ipynb' file. It is a Jupyter Notebook that you can run through completely to get historical data loaded into BigQuery.

The SQL scripts used for BigQuery are in the BigQuerySQLScripts folder. The SQL scripts with '_report' at the end are used to create the views that are used to generate the data reports (not sent to the dashboard). The SQL scripts with '_deduplicated' at the end are used to create the views that load deduplicated data into the dashboard on Looker Studio.

The Airflow Dag is composed of everything else. The DAG can be found in the daily_update.py file.

The BigQuery instance can be found at: https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1schainlink-455803!2sProd_1

The dashboard can be found at: https://lookerstudio.google.com/reporting/f378ca82-d934-4b8b-aa33-bcd0d01a2489

