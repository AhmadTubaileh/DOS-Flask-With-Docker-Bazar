FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY order.py .

#start listening on 5001 port (not open on my pc)
EXPOSE 5001

CMD ["python", "order.py"]
