# Create a DAG that runs a python function
# Create a DAG that runs only manually and calls a python function which should print:  “This is a python script”
# DAG name should be: “airflow_i_ex_4”
# Check that your DAG is running successfully and the output is correct.

from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator


def python_script():
    print("this is a python script")


default_args = {
    "start_date": datetime(2024, 1, 1),
}

with DAG(
    dag_id="airflow_i_ex_4",
    default_args=default_args,
    schedule=None,  # manual only
    catchup=False,
    tags=['bblue']
) as dag:

    task_1 = PythonOperator(
        task_id="task_1", python_callable=python_script
    )

    task_1
