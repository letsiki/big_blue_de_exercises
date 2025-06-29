from airflow import DAG
from airflow.decorators import task

# from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.discord.operators.discord_webhook import DiscordWebhookOperator
from typing import List
from datetime import datetime
from faker import Faker
from random import randint

start_date = datetime(2025, 6, 29)


@task
def task_create_table_if_not_exist():
    hook = PostgresHook(postgres_conn_id="my_postgres_conn")
    conn = hook.get_conn()
    cursor = conn.cursor()

    # Persmission denied, must use an existing schema
    # cursor.execute("CREATE SCHEMA IF NOT EXISTS analytics;")

    cursor.execute(
        """CREATE TABLE IF NOT EXISTS products_not_in_stock_alex_andrio (
	        "order_id" SERIAL NOT NULL UNIQUE,
	        "order_date" date NOT NULL,
	        "store_id" bigint NOT NULL,
	        "product_name" varchar(255) NOT NULL,
           PRIMARY KEY ("order_id")
           );
        """
    )
    conn.commit()


@task
def task_upsert_records(rows: List[tuple], reset=False):

    with PostgresHook(postgres_conn_id="my_postgres_conn").get_conn() as conn:
        with conn.cursor() as cur:
            if reset:
                cur.execute(
                    "TRUNCATE TABLE products_not_in_stock_alex_andrio RESTART IDENTITY;"
                )
            # 3 arguments means insert with auto-icremented order_id
            if all(map(lambda x: len(x) == 3, rows)):
                sql = """
                    INSERT INTO products_not_in_stock_alex_andrio (order_date, store_id, product_name)
                VALUES (%s, %s, %s)
                    """

            # 4 arguments means update
            elif all(map(lambda x: len(x) == 4, rows)):
                columns = ["order_id", "order_date", "store_id", "product_name"]
                rows = [dict(zip(columns, row)) for row in rows]
                sql = """
                UPDATE products_not_in_stock_alex_andrio
                SET 
                    order_date = %(order_date)s,
                    store_id = %(store_id)s,
                    product_name = %(product_name)s
                WHERE order_id = %(order_id)s
                """

            else:
                raise ValueError("Invalid Input")
            cur.executemany(sql, rows)
        conn.commit()


@task.short_circuit
def sc_check_records():
    with PostgresHook(postgres_conn_id="my_postgres_conn").get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("select count(*) > 5 from products_not_in_stock_alex_andrio")
            return cur.fetchone()[0]


# @task
# def send_notification():
#     pass


def generate_random_rows(n: int):
    fkr = Faker()
    return [
        (
            fkr.date(end_datetime=datetime(2022, 12, 31)),
            randint(1, 100),
            fkr.catch_phrase(),
        )
        for _ in range(n)
    ]


with DAG(dag_id="day_2_dag", start_date=start_date):

    notify = DiscordWebhookOperator(
        task_id="notify_discord",
        message="More than 5 products are no longer in stock please resolve!",
        http_conn_id="discord_conn_id",
        # username="StockNotifierBot"
    )

    (
        task_create_table_if_not_exist()
        >> task_upsert_records(generate_random_rows(6), reset=True)
        >> sc_check_records()
        >> notify
    )
