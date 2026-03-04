from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id='saas_mysql_pipeline',
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily',
    catchup=False
) as dag:

    run_pipeline = BashOperator(
        task_id='run_saas_pipeline_script',
        bash_command='python /opt/airflow/scripts/saas_pipeline_final_code.py'
    )

    run_pipeline