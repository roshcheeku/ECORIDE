from db_config import app, db

class Carpool(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    driver_name = db.Column(db.String(100), nullable=False)
    source = db.Column(db.String(100), nullable=False)
    destination = db.Column(db.String(100), nullable=False)
    arrival_time = db.Column(db.DateTime, nullable=False)
    route = db.Column(db.String(100), nullable=False)
    passengers = db.Column(db.String(100))  # CSV for simplicity

# Create all tables within the application context
with app.app_context():
    db.create_all()

print("Database tables created successfully!")
