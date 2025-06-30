# DynamDynamic task creation - Bonus
# Create a DAG with 7 tasks. You don’t have to define them explicitly like we did in exercise 3, define them dynamically inside a loop.
# Make sure you use a different name for each task, as duplicate names are not allowed! Hint: Define task names and print messages dynamically
# Each task has to print the id of the task
# (e.g. task n.5 will print “This is task 5” )
# Check that your DAG exists, run it and check output.
# i. Print the message in bash script. DAG name should be: “airflow_i_ex_5_i”
# ii. Print the message by calling a python function. DAG name should be: “airflow_i_ex_5_ii”ic task creation - Bonus
# Create a DAG with 7 tasks. You don’t have to define them explicitly like we did in exercise 3, define them dynamically inside a loop.
# Make sure you use a different name for each task, as duplicate names are not allowed! Hint: Define task names and print messages dynamically
# Each task has to print the id of the task
# (e.g. task n.5 will print “This is task 5” )

# Check that your DAG exists, run it and check output.
# i. Print the message in bash script. DAG name should be: “airflow_i_ex_5_i”
# ii. Print the message by calling a python function. DAG name should be: “airflow_i_ex_5_ii”

from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator


default_args = {
    "start_date": datetime(2024, 1, 1),
}

# Bash Operator

with DAG(
    dag_id="airflow_i_ex_5_i",
    default_args=default_args,
    schedule=None,  # manual only
    catchup=False,
) as dag:

    tasks = []
    for i in range(1, 8):
        task = BashOperator(task_id=f"task_{i}", bash_command='echo "This is task {i}"')
        tasks.append(task)

    # by creating the dependencies we can clearly see that everything ran in order
    # without it order was random
    for i in range(len(tasks) - 1):
        tasks[i] >> tasks[i + 1]

# Python Operator


def python_script(task_nr):
    print(f"This is task {i}")


with DAG(
    dag_id="airflow_i_ex_5_ii",
    default_args=default_args,
    schedule=None,  # manual only
    catchup=False,
    tags=['bblue']
) as dag:

    tasks = []
    for i in range(1, 8):
        task = PythonOperator(
            task_id=f"task_{i}", python_callable=python_script, op_args=(i,)
        )
        tasks.append(task)

    # by creating the dependencies we can clearly see that everything ran in order
    # without it order was random
    for i in range(len(tasks) - 1):
        tasks[i] >> tasks[i + 1]
