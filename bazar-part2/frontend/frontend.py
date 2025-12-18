from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

cache = {}

catalog_servers = ["http://catalog1:5000", "http://catalog2:5000"] #two servers for load balancing instead of one (if one server is overloaded, the other one can handle the requests)
order_servers = ["http://order1:5001", "http://order2:5001"]

catalog_index = 0
order_index = 0

def catalog_server(): #the purpose of this function is to get the next catalog server in the list, so to make it distributed load balancing (no overloading one server)
    global catalog_index
    server = catalog_servers[catalog_index] #get the next available server in the list
    catalog_index = (catalog_index+1) % len(catalog_servers) #len=length of the array
    return server

def order_server():
    global order_index
    server = order_servers[order_index]
    order_index = (order_index+1) % len(order_servers)
    return server



@app.route('/info/<int:id>', methods=['GET'])
def info (id):

    key = f"info:{id}" #key = info:1 (so the cache will be like {"info:1": {"book_id":1, "title":"How to get a good grade in DOS in 40 minutes a day", "topic":"distributed systems", "price":40, "quantity":10}})
    if key in cache: #if info:1 as example is already in the cache, return the value
        return jsonify(cache[key]), 200
    
    server = catalog_server()
    info = requests.get(f"{server}/info/{id}")

    if info.status_code != 200:
        return jsonify({"error":"The book was not found"}),404
    
    book = info.json()

    cache[key] = book #add the book to the cache since it was not in the cache

    return jsonify({
        "book_id":id,
        "title":book['title'],
        "topic": book['topic'],
        "price": book['price'],
        "quantity": book['quantity']
        }),200



    
@app.route("/search/<topic>", methods=['GET'])
def search(topic):

    key = f"search:{topic}"
    if key in cache:
        return jsonify(cache[key]), 200
    

    if not topic:
        return jsonify({"error": "topic is missing"}), 400

    server = catalog_server()
    titles = requests.get(f"{server}/search/{topic}")

    if titles.status_code !=200:
        return jsonify({"error":"The topic was not found"}),404 
    
    bookTitles = titles.json()
    cache[key] = bookTitles
    
    return jsonify(bookTitles), 200

 




@app.route("/purshase", methods=['POST'])
def purshase():

    data = request.get_json()
    book_id = data.get("book_id")

    if not book_id:
        return jsonify({"error": "book_id is missing"}), 400
    
    server = order_server()
    purchas = requests.post(f"{server}/purshase", json={"book_id":book_id})

    if purchas.status_code !=200:
        return jsonify({"error":"failed to update catalog or Out of stock"}),500
    
    return jsonify(purchas.json()),200



@app.route("/invalidate", methods=['POST'])
def invalidate():
    data = request.get_json()
    book_id = data.get("book_id")

    if not book_id:
        return jsonify({"error": "book_id is missing"}), 400

    info_key = f"info:{book_id}"
    cache.pop(info_key, None) #pop the info:number from the cache|| if info:1 is not in the cache then the default value is None
    
    return jsonify({"message": "Cache has been invalidated","book_id":book_id}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0",port = 5002, debug=True)