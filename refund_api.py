from flask import Flask, jsonify
from refund_service import request_refund

app = Flask(__name__)


@app.post("/orders/<order_no>/refund-request")
def create_refund_request(order_no):
    result = request_refund(order_no)
    return jsonify(result)


if __name__ == "__main__":
    app.run(debug=True)