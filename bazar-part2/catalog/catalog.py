from flask import Flask, jsonify, request
import csv
import os
import requests #for try/exception of replication


app = Flask(__name__)

OTHER_CATALOG_URL = os.getenv("OTHER_CATALOG_URL")  # set by docker compose (in catalog1 it will be catalog2 and in catalog2 it will be catalog1)


def load_books():
    books =[]
    with open("catalog.csv",mode="r", newline='', encoding="utf-8") as file:
        reader = csv.DictReader(file) #dict => dictionary

        for row in reader: #csv => stores as string so numerics need to be as integers.
           row["id"] = int(row["id"])
           row["price"] = int(row["price"])
           row["quantity"] = int(row["quantity"])
           books.append(row)

    return books


def save_books(books):
    with open("catalog.csv", mode="w", newline='', encoding="utf-8") as file:
        fieldnames = ["id", "title", "topic", "price", "quantity"]
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader() #header taken from fieldnames above
        writer.writerows(books)


books = load_books()
           


@app.route('/')
def home():
        return "welcome to bazar"



@app.route('/search/<topic>', methods=['GET'])
def search(topic):
        result=[]
        for b in books:
            if b["topic"]==topic:
                   result.append({"id":b['id'],"Title":b['title']})
        return jsonify(result),200
                
        
@app.route('/info/<int:id>', methods =['GET'])
def info(id):

    for b in books:
        if b['id'] == id:
            return jsonify({
                  "title": b["title"],
                  "topic": b["topic"],
                  "price": b["price"],
                  "quantity": b["quantity"]
            }),200
    
    return jsonify({"error": "book not found"}) , 404



@app.route('/update', methods=['POST'])
def update():
    data = request.get_json()
    book_id = data.get("book_id")

    for b in books:
        if b['id'] ==book_id:
            if b['quantity'] >0:
                b["quantity"] -=1
                save_books(books)

                if OTHER_CATALOG_URL:
                    try:
                        requests.post(f"{OTHER_CATALOG_URL}/replica_update", json={"book_id":book_id})
                    except requests.RequestException as e:
                        print("Warning: replication failed: ",e)

                return jsonify({"message": "Quantity has been updated ",
                                "remaining":b["quantity"]
                                }),200
            else:
                return jsonify({"error":"Book is out of stock"}), 400
    
    return jsonify ({"error":"Book not found"}),404


    
@app.route('/replica_update', methods=['POST'])
def replica_update():
    data = request.get_json()
    book_id = data.get("book_id")

    for b in books:
        if b['id'] ==book_id:
            if b['quantity'] >0:
                b["quantity"] -=1
                save_books(books)

                return jsonify({"message": "Replica Quantity has been updated ",
                                "remaining":b["quantity"]
                                }),200
            else:
                return jsonify({"error":"Book is out of stock"}), 400
    
    return jsonify ({"error":"Book not found"}),404


    



if(__name__) == '__main__':
        app.run(host="0.0.0.0",port =5000,debug = True)

