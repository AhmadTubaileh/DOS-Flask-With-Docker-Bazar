from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

catalogURL = "http://catalog:5000"

@app.route('/purshase', methods =['POST'])
def purshase():

    data = request.get_json() #get data from fronend
    book_id = data.get("book_id") 

    if not book_id: #if it was ""
        return jsonify({"error": "book_id is missing"}), 400

    info = requests.get(f"{catalogURL}/info/{book_id}")# get is same as GET

    if info.status_code !=200: #if not ok(200) then ...
        return jsonify({"error":"The book wasnt found"}),404
    
    book = info.json() #turns info into json {"bla bla": value}
    
    if book["quantity"] <=0:
        return jsonify({"error": "Out of stock"}),400
    
    update = requests.post(f"{catalogURL}/update", json = {"book_id":book_id}) #send the update with json body for the book to decrease quantity

    if update.status_code !=200:
        return jsonify({"error":"failed to update catalog"}),500
    
    return jsonify({
        "message": f"you have successfully purcahsed '{book['title']}' for ${book['price']}",
        "remaining":book['quantity']-1
    }),200

    



if __name__=="__main__":
    app.run(host="0.0.0.0", port =5001,debug=True)