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

def is_matching_route(driver_route, passenger_route, threshold=0.5):
    for p_point in passenger_route:
        if not any(calculate_distance(p_point, d_point) <= threshold for d_point in driver_route):
            return False
    return True

def calculate_expected_departure(arrival_time, distance):
    travel_time_hours = distance / AVERAGE_SPEED
    travel_time = timedelta(hours=travel_time_hours)
    return arrival_time - travel_time

def is_timing_matching(driver_arrival_time, passenger_arrival_time, distance):
    driver_expected_departure = calculate_expected_departure(driver_arrival_time, distance)
    return passenger_arrival_time >= driver_expected_departure

class User:
    def _init_(self, name, source, destination, arrival_time):
        self.name = name
        self.source = geocode_location(source)
        self.destination = geocode_location(destination)
        self.arrival_time = arrival_time

        if self.source and self.destination:
            self.route = get_route(self.source, self.destination)
        else:
            print(f"Could not get route for {name}.")

class CarpoolSystem:
    def _init_(self, driver, max_passengers=3):
        self.driver = driver
        self.max_passengers = max_passengers
        self.passengers = []

    def add_passenger(self, passenger):
        if len(self.passengers) < self.max_passengers:
            distance = calculate_distance(self.driver.source, self.driver.destination)

            if is_matching_route(self.driver.route, passenger.route) and \
               is_timing_matching(self.driver.arrival_time, passenger.arrival_time, distance) and \
               not is_opposite_direction(self.driver.route, passenger.route):
                self.passengers.append(passenger)
                print(f"Passenger {passenger.name} added to the carpool.")
            else:
                print(f"Passenger {passenger.name}'s route or timings do not match or they are traveling in the opposite direction.")
        else:
            print("Carpool is full.")

    def cluster_passengers(self):
        if not self.passengers:
            print("No passengers to cluster.")
            return

        # Combine driver and passenger routes for clustering
        all_routes = [self.driver.route] + [p.route for p in self.passengers]
        
        # Flatten routes into a list of points with an associated route index
        route_points = []
        route_indices = []
        for route_index, route in enumerate(all_routes):
            for point in route:
                route_points.append(point)
                route_indices.append(route_index)
        
        # Convert points to a numpy array for clustering
        route_points_np = np.radians(np.array(route_points))

        # Perform DBSCAN clustering
        dbscan = DBSCAN(eps=0.01, min_samples=1, metric='haversine')
        labels = dbscan.fit_predict(route_points_np)
        
        # Create a mapping from route indices to clusters
        clusters = {}
        for route_index in set(route_indices):
            clusters[route_index] = []

        for point_label, route_index in zip(labels, route_indices):
            clusters[route_index].append(point_label)

        # Group clusters by their labels
        grouped_clusters = {}
        for route_index, labels in clusters.items():
            cluster_label = min(labels)  # Take the lowest label to identify the cluster
            if cluster_label not in grouped_clusters:
                grouped_clusters[cluster_label] = []
            grouped_clusters[cluster_label].append(route_index)
        
        print("\nClustered Routes:")
        for cluster_id, routes in grouped_clusters.items():
            print(f"Cluster {cluster_id}:")
            for route_index in routes:
                if route_index == 0:
                    print(f"  Driver's Route: {all_routes[route_index]}")
                else:
                    passenger = self.passengers[route_index - 1]
                    print(f"  Passenger {passenger.name}'s Route: {all_routes[route_index]}")

        # Driver reviews clusters and selects passengers
        for cluster_id, routes in grouped_clusters.items():
            accept = input(f"Do you want to accept passengers from Cluster {cluster_id}? (yes/no): ").strip().lower()
            if accept == 'yes':
                for route_index in routes:
                    if route_index != 0:
                        passenger = self.passengers[route_index - 1]
                        print(f"Passenger {passenger.name} from Cluster {cluster_id} accepted.")
            else:
                print(f"Cluster {cluster_id} declined.")

if __name__ == "_main_":
    driver_name = input("Enter driver's name: ")
    driver_source = input("Enter driver's source location: ")
    driver_destination = input("Enter driver's destination location: ")
    driver_arrival_time = input("Enter driver's arrival time (YYYY-MM-DD HH:MM): ")
    driver_arrival_time = datetime.strptime(driver_arrival_time, "%Y-%m-%d %H:%M")

    max_passengers = int(input("Enter the maximum number of passengers the driver wants to accept: "))
    driver = User(driver_name, driver_source, driver_destination, driver_arrival_time)
    carpool = CarpoolSystem(driver, max_passengers)

    while len(carpool.passengers) < carpool.max_passengers:
        passenger_name = input("Enter passenger's name: ")
        passenger_source = input("Enter passenger's source location: ")
        passenger_destination = input("Enter passenger's destination location: ")
        passenger_arrival_time = input("Enter passenger's arrival time (YYYY-MM-DD HH:MM): ")
        passenger_arrival_time = datetime.strptime(passenger_arrival_time, "%Y-%m-%d %H:%M")
        
        passenger = User(passenger_name, passenger_source, passenger_destination, passenger_arrival_time)
        carpool.add_passenger(passenger)

    print("Carpool is full or all passengers added.")
    carpool.cluster_passengers()