from datetime import datetime
from airflow.decorators import task
from docker.types import Mount
from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from datetime import datetime
from airflow.providers.discord.operators.discord_webhook import (
    DiscordWebhookOperator,
)
from airflow.utils.trigger_rule import TriggerRule
from airflow.exceptions import AirflowException


@task.branch
def branch_choose_message_task(state: bool):
    return (
        "generate_success_message"
        if state
        else "generate_failure_message"
    )


@task(trigger_rule=TriggerRule.ALL_SUCCESS)
def generate_success_message():
    return "✅ Karieragr report ready - check ~/Documents/Bind-Mounts/karieragr/daily-urls/"


@task(trigger_rule=TriggerRule.ALL_FAILED)
def generate_failure_message():
    return "❌ Karieragr scraping failed."


@task(trigger_rule=TriggerRule.ONE_SUCCESS)
def join(s: str):
    return s


@task(trigger_rule=TriggerRule.ONE_FAILED, retries=0)
def watcher():
    raise AirflowException(
        "Failing task because one or more upstream tasks failed."
    )


with DAG(
    dag_id="karieragr-scraping",
    start_date=datetime(2025, 6, 28),
    schedule="8 9,15 * * *",
    catchup=False,
    tags=["bblue"],
) as dag:

    # --- DockerOperator Task
    scraper_task = DockerOperator(
        task_id="scraper",
        image="karieragrscraper:latest",
        auto_remove="force",  # correct in Airflow 3.0+,
        tty=True,
        mount_tmp_dir=False,
        mounts=[
            Mount(
                source="/home/alex/Documents/Bind-Mounts/karieragr",  # host path
                target="/app/data/daily-urls",  # container path
                type="bind",
            )
        ],
        docker_url="unix://var/run/docker.sock",
        network_mode="db-compose_default",
        environment={"POSTGRES_HOST": "my-postgres"},
    )

    discord_notify_task = DiscordWebhookOperator(
        task_id="notify_discord",
        message="{{ ti.xcom_pull(task_ids='join') }}",
        http_conn_id="discord_conn_id",
    )

    generate_success_message_task = generate_success_message()
    generate_failure_message_task = generate_failure_message()

    (
        scraper_task
        >> branch_choose_message_task(scraper_task)
        >> [
            generate_success_message_task,
            generate_failure_message_task,
        ]
        >> join(
            [
                generate_success_message_task,
                generate_failure_message_task,
            ]
        )
        >> discord_notify_task
    )
    list(dag.tasks) >> watcher()
