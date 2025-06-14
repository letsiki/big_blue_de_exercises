FROM python:3.9

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

RUN mkdir csv

RUN apt-get update

RUN apt install cron -y

RUN apt install systemctl -y

RUN systemctl start cron

RUN echo "* * * * * /usr/local/bin/python /app/webscraper.py >> /var/log/cron.log 2>&1" > /etc/cron.d/webscraper-cron \
    && chmod 0644 /etc/cron.d/webscraper-cron \
    && crontab /etc/cron.d/webscraper-cron

CMD ["cron", "-f"]


