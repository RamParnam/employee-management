from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)

DATA_FILE = "employees.json"


def load_employees():
    if not os.path.exists(DATA_FILE):
        return []

    with open(DATA_FILE, "r") as file:
        return json.load(file)


def save_employees(employees):
    with open(DATA_FILE, "w") as file:
        json.dump(employees, file, indent=4)


@app.route("/health")
def health():
    return jsonify({
        "status": "UP"
    })


@app.route("/employees", methods=["GET"])
def get_employees():
    return jsonify(load_employees())


@app.route("/employees", methods=["POST"])
def add_employee():

    employee = request.get_json()

    employees = load_employees()

    employees.append(employee)

    save_employees(employees)

    return jsonify({
        "message": "Employee Added Successfully"
    }), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
