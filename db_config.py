# db_config.py
from flask_sqlalchemy import SQLAlchemy
from flask import Flask

app = Flask(__name__)

# SQLite example (or replace with MySQL/Postgres connection string)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///carpool.db'  
db = SQLAlchemy(app)
