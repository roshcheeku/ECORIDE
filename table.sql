mysql> CREATE TABLE users (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     login_id VARCHAR(100) NOT NULL,
    ->     username VARCHAR(100) NOT NULL,
    ->     email VARCHAR(100) NOT NULL,
    ->     gender ENUM('male', 'female', 'other'),
    ->     profile_picture VARCHAR(255),
    ->     location VARCHAR(100),
    ->     age INT,
    ->     role ENUM('driver', 'passenger') NOT NULL,
    ->     source_id INT,
    ->     destination_id INT,
    ->     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ->     FOREIGN KEY (source_id) REFERENCES locations(id),
    ->     FOREIGN KEY (destination_id) REFERENCES locations(id)
    -> );
mysql> CREATE TABLE locations (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     name VARCHAR(100) NOT NULL
    -> );
