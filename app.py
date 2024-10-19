from flask import Flask, request, jsonify
from datetime import datetime
from driver import User, CarpoolSystem  # Correct import

app = Flask(__name__)

carpool_systems = {}

@app.route('/initiate_carpool', methods=['POST'])
def initiate_carpool():
    data = request.get_json()
    driver_name = data['driver_name']
    source = data['source']
    destination = data['destination']
    arrival_time = datetime.strptime(data['arrival_time'], "%Y-%m-%d %H:%M")
    max_passengers = data['max_passengers']
    driver = User(driver_name, source, destination, arrival_time)
    carpool_systems[driver_name] = CarpoolSystem(driver, max_passengers)
    return jsonify({"message": "Carpool created successfully"}), 200

@app.route('/join_carpool', methods=['POST'])
def join_carpool():
    data = request.get_json()
    driver_name = data['driver_name']
    passenger_name = data['passenger_name']
    source = data['source']
    destination = data['destination']
    arrival_time = datetime.strptime(data['arrival_time'], "%Y-%m-%d %H:%M")
    passenger = User(passenger_name, source, destination, arrival_time)

    if driver_name in carpool_systems:
        carpool_system = carpool_systems[driver_name]
        carpool_system.add_passenger(passenger)
        return jsonify({"message": f"Passenger {passenger_name} added to the carpool"}), 200
    else:
        return jsonify({"message": "Carpool not found"}), 404

@app.route('/cluster_passengers', methods=['GET'])
def cluster_passengers():
    driver_name = request.args.get('driver_name')
    
    if driver_name in carpool_systems:
        carpool_system = carpool_systems[driver_name]
        carpool_system.cluster_passengers()
        return jsonify({"message": "Passengers clustered successfully"}), 200
    else:
        return jsonify({"message": "Carpool not found"}), 404

if __name__ == '__main__':
    app.run(debug=True)
