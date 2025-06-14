FROM python:3.9

RUN apt-get update && apt-get install -y cron vim nano

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

RUN mkdir -p csv && touch /var/log/cron.log

RUN chmod +x /app/webscraper-postgres.py

RUN printf "PASSWORD=docker\nHOST=postgres-db\nPORT=5432\n* * * * * /usr/local/bin/python /app/webscraper-postgres.py >> /var/log/cron.log 2>&1\n" > cronjob && crontab cronjob

CMD ["cron", "-f"]
