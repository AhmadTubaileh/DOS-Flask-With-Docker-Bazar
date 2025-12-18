from flask import Flask, jsonify, request

app = Flask(__name__)

books=[{"id":1, "title":"How to get a good grade in DOS in 40 minutes a day","topic":"distributed systems","price":40,"quantity":10},
       {"id":2, "title":"RPCs for Noobs","topic":"distributed systems","price":50,"quantity":5},
       {"id":3, "title":"Xen and the Art of Surviving Undergraduate School","topic":"undergraduate school","price":35,"quantity":8},
       {"id":4, "title":"Cooking for the Impatient Undergraduate","topic":"undergraduate school","price":25,"quantity":3}]

@app.route('/')
def home():
        return "welcome to bazar"



@app.route('/search/<topic>', methods=['GET'])
def search(topic):
        result=[]
        for b in books:
            if b["topic"]==topic:
                   result.append(b)
        return jsonify(result),200
                
        
@app.route('/info/<int:id>', methods =['GET'])
def info(id):
    result=[]
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
                return jsonify({"message": "Quantity has been updated",
                                "remaining":b["quantity"]
                                }),200
            else:
                return jsonify({"error":"Book is out of stock"}), 400
    
    return jsonify ({"error":"Book not found"}),404


    
    



if(__name__) == '__main__':
        app.run(host="0.0.0.0",port =5000,debug = True)

