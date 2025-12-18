FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY frontend.py .

#start listening on 5002 port (not open on my pc)
EXPOSE 5002 

CMD ["python", "frontend.py"]

