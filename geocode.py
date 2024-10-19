from flask import Flask, request, jsonify
import requests
import time

app = Flask(__name__)

GRAPHOPPER_API_KEY = 'a72be5cd-0912-48d6-8eae-089c71ed045e'

def geocode(address):
    url = "https://nominatim.openstreetmap.org/search"
    headers = {
        'User-Agent': 'CarpoolingApp/1.0 (your_email@example.com)'  # Replace with your app name and email
    }
    params = {
        'q': address,
        'format': 'json',
        'limit': 1
    }
    
    time.sleep(1)
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200 and response.json():
        location = response.json()[0]
        return float(location['lat']), float(location['lon'])
    return None, None

def calculate_price(start_lat, start_lng, end_lat, end_lng):
    url = f"https://graphhopper.com/api/1/route"
    params = {
        'point': [f'{start_lat},{start_lng}', f'{end_lat},{end_lng}'],
        'vehicle': 'car',
        'key': GRAPHOPPER_API_KEY
    }

    response = requests.get(url, params=params)
    if response.status_code == 200:
        data = response.json()
        distance_meters = data['paths'][0]['distance']
        distance_km = distance_meters / 1000
        return distance_km * 15  # Assuming 15 currency units per km
    return None

@app.route('/calculate_price', methods=['POST'])
def calculate_price_api():
    data = request.json
    start_address = data.get('start_address')
    end_address = data.get('end_address')
    
    start_lat, start_lng = geocode(start_address)
    end_lat, end_lng = geocode(end_address)

    if start_lat is None or end_lat is None:
        return jsonify({'error': 'Unable to geocode addresses'}), 400
    
    price = calculate_price(start_lat, start_lng, end_lat, end_lng)
    
    if price is not None:
        return jsonify({'price': price}), 200
    else:
        return jsonify({'error': 'Unable to calculate the price'}), 500

if __name__ == '__main__':
    app.run(debug=True)
