# coding: utf-8

from bs4 import BeautifulSoup
import requests
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from sqlalchemy.sql import text
from datetime import datetime
import os


url = "https://www.atptour.com/en/rankings/singles?rankRange=0-200"
headers = {"User-Agent": ""}
response = requests.get(url, timeout=15, headers=headers)
if response.status_code == 200:
    soup = BeautifulSoup(response.content, "html.parser")
    rows = soup.find(
        "table", {"class": "mega-table desktop-table non-live"}
    ).find_all("tr")
    lst = []
for row in rows[1:]:
    # Ranking
    try:
        ranking = (
            row.find("td", {"class": "rank bold heavy tiny-cell"})
            .get_text()
            .strip()
        )
    except:
        ranking = np.nan
    # Country
    try:
        country = (
            row.find("li", {"class": "avatar"})
            .find("svg", {"class": "atp-flag flag"})
            .find("use")
            .get("href", "")
            .split("#flag-")[-1]
            .upper()
        )
    except:
        country = np.nan
    # Player
    try:
        player = (
            row.find("li", {"class": "name center"}).get_text().strip()
        )
    except:
        player = np.nan
    # Age
    try:
        age = row.find("td", {"class": "age"}).get_text().strip()
    except:
        age = np.nan
    # Points
    try:
        points = (
            row.find(
                "td",
                {"class": "points center bold extrabold small-cell"},
            )
            .get_text()
            .strip()
        )
    except:
        points = np.nan
    # Tournaments
    try:
        tournaments = (
            row.find("td", {"class": "tourns center small-cell"})
            .get_text()
            .strip()
        )
    except:
        tournaments = np.nan
    # Points dropping
    try:
        points_dropping = (
            row.find("td", {"class": "drop center small-cell"})
            .get_text()
            .strip()
        )
    except:
        points_dropping = np.nan
    # Next best
    try:
        next_best = (
            row.find("td", {"class": "best center small-cell"})
            .get_text()
            .strip()
        )
    except:
        next_best = np.nan

    temp = {
        "ranking": ranking,
        "country": country,
        "player": player,
        "age": age,
        "points": points,
        "tournaments": tournaments,
        "points_dropping": points_dropping,
        "next_best": next_best,
        "date_time": datetime.now().strftime(
            "%d/%m/%Y %H:%M:%S"
        ),  # we add the current date and time
    }
    lst.append(temp)

else:
    print("Scraper is down!")

df = pd.DataFrame(lst)
df = df.dropna(thresh=3)

# we are saving our dataframe as csv file to our container's /app/csv directory.
# if the csv file doesn't exist we create it and if it does we append the new csv to
# the existing one
if not os.path.isfile("/app/csv/atp-rankings.csv"):
    df.to_csv("/app/csv/atp-rankings.csv", index=False)
else:
    df.to_csv(
        "/app/csv/atp-rankings.csv", mode="a", index=False, header=False
    )


engine = create_engine(
    "postgresql+psycopg2://"
    f"postgres:"  # username for postgres
    f"{os.environ['PASSWORD']}"  # password for postgres
    f"@{os.environ['HOST']}:{os.environ['PORT']}/"  # postgres server name and the exposed port
    "postgres"
)

con = engine.connect()

# create an empty table tennis
sql = """
  create table if not exists tennis (
  ranking int,
  country CHAR(3),
  player VARCHAR(50),
  age int,
  points VARCHAR(50),
  tournaments int,
  points_dropping VARCHAR(50),
  next_best VARCHAR(50),
  date_time VARCHAR(50)
);
"""
# execute the 'sql' query
with engine.connect().execution_options(autocommit=True) as conn:
    query = conn.execute(text(sql))

# insert the dataframe data to 'tennis' SQL table
with engine.connect().execution_options(autocommit=True) as conn:
    df.to_sql("tennis", con=conn, if_exists="append", index=False)

# optional
print(
    pd.read_sql_query(
        """
select * from tennis
""",
        con,
    )
)
