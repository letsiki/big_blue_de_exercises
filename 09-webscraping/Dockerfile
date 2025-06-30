FROM python:3.11.11-slim-bookworm

WORKDIR /app

COPY requirements.txt atp-scraper.py ./

RUN pip install -r requirements.txt

CMD ["python", "atp-scraper.py"]