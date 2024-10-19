import mysql.connector
from mysql.connector import Error

def create_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',        
            user='root',          
            password='root123', 
            database='api_database'  
        )
        if connection.is_connected():
            print("Connected to MySQL database")
            return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

# Test the connection
if __name__ == "__main__":
    conn = create_connection()
    if conn:
        conn.close()