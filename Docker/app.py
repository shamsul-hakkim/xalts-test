from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    response = {
        "result": "Healthy", 
        "error": "False"
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True)
