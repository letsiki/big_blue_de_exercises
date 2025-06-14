FROM python:3.9

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

RUN mkdir csv

CMD ["python", "webscraper.py"]


