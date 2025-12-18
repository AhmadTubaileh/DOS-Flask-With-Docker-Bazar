FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY catalog.py .

COPY catalog1.csv .
COPY catalog2.csv .

#start listening on 5000 port (not open on my pc)
EXPOSE 5000

CMD ["python", "catalog.py"]
