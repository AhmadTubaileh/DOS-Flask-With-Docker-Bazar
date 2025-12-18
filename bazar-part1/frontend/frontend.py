from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

orderURL = "http://order:5001"
catalogURL = "http://catalog:5000"

#to do: info, search, purshase

@app.route('/info/<int:id>', methods=['GET'])
def info (id):

    if not id:
        return jsonify({"error": "book_id is missing"}), 400

    info = requests.get(f"{catalogURL}/info/{id}")

    if info.status_code != 200:
        return jsonify({"error":"The book was not found"}),404
    
    book = info.json()

    return jsonify({
        "book_id":id,
        "title":book['title'],
        "topic": book['topic'],
        "price": book['price'],
        "quantity": book['quantity']
        }),200



    
@app.route("/search/<topic>", methods=['GET'])
def search(topic):

    if not topic:
        return jsonify({"error": "opic is missing"}), 400
    
    titles = requests.get(f"{catalogURL}/search/{topic}")

    if titles.status_code !=200:
        return jsonify({"error":"The topic was not found"}),404
    
    return jsonify(titles.json()), 200

 




@app.route("/purshase", methods=['POST'])
def purshase():

    data = request.get_json()
    book_id = data.get("book_id")

    if not book_id:
        return jsonify({"error": "book_id is missing"}), 400
    
    purchas = requests.post(f"{orderURL}/purshase", json={"book_id":book_id})

    if purchas.status_code !=200:
        return jsonify({"error":"failed to update catalog or Out of stock"}),500
    
    return jsonify(purchas.json()),200






if __name__ == "__main__":
    app.run(host="0.0.0.0",port = 5002, debug=True)