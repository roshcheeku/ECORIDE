import requests
from geopy.distance import geodesic
import polyline
from datetime import datetime, timedelta
import numpy as np
from sklearn.cluster import DBSCAN

GRAPHOPPER_API_KEY = 'a72be5cd-0912-48d6-8eae-089c71ed045e'
BANGALORE_BBOX = {
    'southwest': (12.7342, 77.3793),
    'northeast': (13.1850, 77.8543)
}
AVERAGE_SPEED = 30

def geocode_location(place):
    url = f"https://graphhopper.com/api/1/geocode"
    params = {
        'q': place,
        'locale': 'en',
        'limit': 1,
        'key': GRAPHOPPER_API_KEY,
        'bbox': f"{BANGALORE_BBOX['southwest'][1]},{BANGALORE_BBOX['southwest'][0]}," \
                f"{BANGALORE_BBOX['northeast'][1]},{BANGALORE_BBOX['northeast'][0]}"
    }
    response = requests.get(url, params=params)
    try:
        data = response.json()
    except ValueError:
        print(f"Error parsing JSON response for place: {place}")
        return None
    if 'hits' in data and data['hits']:
        lat = data['hits'][0]['point']['lat']
        lng = data['hits'][0]['point']['lng']
        return (lat, lng)
    return None

def decode_polyline(encoded_points):
    return [(lat, lng) for lng, lat in polyline.decode(encoded_points)]

def get_route(source, destination):
    url = f"https://graphhopper.com/api/1/route"
    params = {
        'point': [f"{source[0]},{source[1]}", f"{destination[0]},{destination[1]}"],
        'vehicle': 'car',
        'locale': 'en',
        'key': GRAPHOPPER_API_KEY,
        'instructions': False
    }
    response = requests.get(url, params=params)
    try:
        data = response.json()
    except ValueError:
        print(f"Error parsing JSON response.")
        return []
    if 'paths' in data and data['paths']:
        path = data['paths'][0]
        if 'points' in path and isinstance(path['points'], str):
            return decode_polyline(path['points'])
    return []

def calculate_distance(coord1, coord2):
    return geodesic(coord1, coord2).km

def bearing(coord1, coord2):
    lat1, lon1 = np.radians(coord1)
    lat2, lon2 = np.radians(coord2)
    diff_lon = lon2 - lon1
    x = np.sin(diff_lon) * np.cos(lat2)
    y = np.cos(lat1) * np.sin(lat2) - np.sin(lat1) * np.cos(lat2) * np.cos(diff_lon)
    initial_bearing = np.arctan2(x, y)
    initial_bearing = np.degrees(initial_bearing)
    compass_bearing = (initial_bearing + 360) % 360
    return compass_bearing

def is_opposite_direction(driver_route, passenger_route, threshold=90):
    if not driver_route or not passenger_route:
        return False
    driver_bearing = bearing(driver_route[0], driver_route[-1])
    passenger_bearing = bearing(passenger_route[0], passenger_route[-1])
    bearing_difference = abs(driver_bearing - passenger_bearing)
    return bearing_difference > threshold

def is_matching_route(driver_route, passenger_route):
    if not driver_route or not passenger_route:
        return False
    for point in passenger_route:
        distances = [calculate_distance(point, driver_point) for driver_point in driver_route]
        if min(distances) < 1:  # Check if any point is within 1 km
            return True
    return False

def is_timing_matching(driver_time, passenger_time, route_distance, time_threshold=timedelta(minutes=15)):
    estimated_duration = timedelta(hours=route_distance / AVERAGE_SPEED)
    driver_time_lower_bound = driver_time - time_threshold
    driver_time_upper_bound = driver_time + estimated_duration + time_threshold
    return driver_time_lower_bound <= passenger_time <= driver_time_upper_bound

class User:
    def __init__(self, name, source, destination, arrival_time):
        self.name = name
        self.source = geocode_location(source)
        self.destination = geocode_location(destination)
        self.arrival_time = arrival_time
        self.route = get_route(self.source, self.destination)

    def __repr__(self):
        return f"User({self.name}, {self.source}, {self.destination}, {self.arrival_time})"

# Example usage:
if __name__ == "__main__":
    # You can test passenger-specific functionality here.
    pass
