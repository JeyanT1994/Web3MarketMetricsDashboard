FROM apache/airflow:latest

USER root
RUN apt-get update && \
    apt-get -y install git && \
    apt-get clean

COPY bigquery_creds.json /etc/

USER airflow