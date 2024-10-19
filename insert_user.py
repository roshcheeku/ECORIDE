import mysql.connector
from mysql.connector import Error

def create_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',        
            user='root',          
            password='root123',  # Ensure this matches your MySQL root password
            database='api_database'  # Database name
        )
        if connection.is_connected():
            print("Connected to MySQL database")
            return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def insert_user(login_id, username, email, gender, profile_picture, location, age, role, source_id=None, destination_id=None):
    try:
        connection = create_connection()
        if connection is None:
            return
        
        cursor = connection.cursor()
        
        insert_query = """
        INSERT INTO users (login_id, username, email, gender, profile_picture, location, age, role, source_id, destination_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        
        data = (login_id, username, email, gender, profile_picture, location, age, role, source_id, destination_id)
        
        cursor.execute(insert_query, data)
        connection.commit()
        print(f"User {username} added to database.")

    except mysql.connector.Error as e:
        print(f"Error: {e}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

# Example usage
if __name__ == "__main__":
    # Taking user input
    login_id = input("Enter login ID: ")
    username = input("Enter username: ")
    email = input("Enter email: ")
    gender = input("Enter gender (male/female/other): ")
    profile_picture = input("Enter profile picture URL or path: ")
    location = input("Enter location: ")
    age = int(input("Enter age: "))  # Convert input to integer
    role = input("Enter role (driver/passenger): ")

    # Optional: Get source and destination IDs if needed
    source_id = input("Enter source ID (leave blank if not applicable): ")
    source_id = input(source_id) if source_id else None
    destination_id = input("Enter destination ID (leave blank if not applicable): ")
    destination_id = input(destination_id) if destination_id else None

    insert_user(login_id, username, email, gender, profile_picture, location, age, role, source_id, destination_id)
