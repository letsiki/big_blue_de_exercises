from bs4 import BeautifulSoup
import requests
import pandas as pd
import numpy as np
from datetime import datetime
import os


url = "https://www.atptour.com/en/rankings/singles?rankRange=0-200"
headers={'User-Agent': ''}
response = requests.get(url,timeout=15, headers=headers)
if response.status_code == 200:
    soup = BeautifulSoup(response.content, "html.parser")
    rows = soup.find("table", {"class": "mega-table desktop-table non-live"}).find_all('tr')
    lst = []
for row in rows[1:]:
        #Ranking
        try:
            ranking = row.find("td", {"class": "rank bold heavy tiny-cell"}).get_text().strip()
        except:
            ranking = np.nan 
        #Country
        try:
            country = row.find("li", {'class': 'avatar'}).find("svg", {"class": "atp-flag flag"}).find("use").get("href", "").split('#flag-')[-1].upper()
        except:
            country = np.nan
        #Player
        try:
            player = row.find("li", {"class": "name center"}).get_text().strip()
        except:
            player = np.nan
        #Age
        try:
            age = row.find("td", {"class": "age"}).get_text().strip()
        except:
            age = np.nan
        #Points
        try:
            points = row.find("td", {"class": "points center bold extrabold small-cell"}).get_text().strip()
        except:
            points = np.nan
        #Tournaments
        try:
            tournaments = row.find("td", {"class": "tourns center small-cell"}).get_text().strip()
        except:
            tournaments = np.nan
        #Points dropping
        try:
            points_dropping = row.find("td", {"class": "drop center small-cell"}).get_text().strip()
        except:
            points_dropping = np.nan
        #Next best
        try:
            next_best = row.find("td", {"class": "best center small-cell"}).get_text().strip()
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
            "date_time": datetime.now().strftime("%d/%m/%Y %H:%M:%S") # we add the current date and time
        }
        lst.append(temp)

else:
    print('Scraper is down!')

df= pd.DataFrame(lst)
df = df.dropna(thresh=3)

# we are saving our dataframe as csv file to our container's /app/csv directory.
# if the csv file doesn't exist we create it and if it does we append the new csv to
# the existing one
if not os.path.isfile('/app/csv/atp-rankings.csv'):
   df.to_csv('/app/csv/atp-rankings.csv', index= False)
else: 
   df.to_csv('/app/csv/atp-rankings.csv', mode='a', index=False, header=False)

# print is not really necessary but is useful for debugging
print(df)