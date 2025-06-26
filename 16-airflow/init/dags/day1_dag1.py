# Create your first DAG
# Create a DAG that runs only manually and consists of 2 tasks:
# - Prints “This is task 1” in bash shell
# - Prints “This is task 2” in bash shell
# DAG name should be: “airflow_i_ex_3”
# Check that your DAG is running successfully and the output is correct.

from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    "start_date": datetime(2024, 1, 1),
}

with DAG(
    dag_id="airflow_i_ex_3",
    default_args=default_args,
    schedule=None,  # manual only
    catchup=False,
) as dag:
    
    task_1 = BashOperator(
        task_id="task_1",
        bash_command='echo "This is task 1"'
    )

    task_2 = BashOperator(
        task_id="task_2",
        bash_command='echo "This is task 2"',
        trigger_rule="all_success"
    )

    task_1 >> task_2



