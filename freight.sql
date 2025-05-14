-- Freight Management System Database

DROP DATABASE IF EXISTS freight_management;
CREATE DATABASE freight_management;
USE freight_management;

-- 1. Vehicle Types Table (Lookup table)
CREATE TABLE vehicle_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- 2. Vehicle Status Table (Lookup table)
CREATE TABLE vehicle_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- 3. Vehicles Table (Lorries, Pickups, Trailers)
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(20) NOT NULL UNIQUE,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    capacity_kg DECIMAL(10,2) NOT NULL,
    type_id INT NOT NULL,
    status_id INT NOT NULL,
    purchase_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    FOREIGN KEY (type_id) REFERENCES vehicle_types(type_id),
    FOREIGN KEY (status_id) REFERENCES vehicle_status(status_id),
    CHECK (capacity_kg > 0)
);

-- 4. Drivers Table
CREATE TABLE drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    license_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    hire_date DATE NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    CHECK (YEAR(hire_date) >= YEAR(date_of_birth) + 18)
);

-- 5. Driver Qualifications Table (M-M relationship)
CREATE TABLE driver_qualifications (
    qualification_id INT AUTO_INCREMENT PRIMARY KEY,
    qualification_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- 6. Driver_Qualification_Junction Table
CREATE TABLE driver_qualification_junction (
    driver_id INT NOT NULL,
    qualification_id INT NOT NULL,
    date_obtained DATE NOT NULL,
    expiry_date DATE,
    PRIMARY KEY (driver_id, qualification_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (qualification_id) REFERENCES driver_qualifications(qualification_id)
);

-- 7. Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT NOT NULL,
    tax_id VARCHAR(50),
    credit_limit DECIMAL(12,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 8. Shipment Status Table (Lookup table)
CREATE TABLE shipment_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- 9. Shipments Table
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    origin_address TEXT NOT NULL,
    destination_address TEXT NOT NULL,
    total_weight_kg DECIMAL(10,2) NOT NULL,
    total_volume_m3 DECIMAL(10,2) NOT NULL,
    pickup_date DATETIME NOT NULL,
    delivery_date DATETIME,
    status_id INT NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (status_id) REFERENCES shipment_status(status_id),
    CHECK (total_weight_kg > 0),
    CHECK (total_volume_m3 > 0),
    CHECK (delivery_date IS NULL OR delivery_date >= pickup_date)
);

-- 10. Trips Table
CREATE TABLE trips (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME,
    start_odometer_km INT NOT NULL,
    end_odometer_km INT,
    fuel_consumption_l DECIMAL(10,2),
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CHECK (end_odometer_km IS NULL OR end_odometer_km >= start_odometer_km),
    CHECK (end_datetime IS NULL OR end_datetime >= start_datetime)
);

-- 11. Maintenance Types Table (Lookup table)
CREATE TABLE maintenance_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- 12. Maintenance Records Table
CREATE TABLE maintenance_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    maintenance_type_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    description TEXT,
    service_provider VARCHAR(100),
    next_maintenance_date DATE,
    odometer_km INT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (maintenance_type_id) REFERENCES maintenance_types(type_id),
    CHECK (cost >= 0),
    CHECK (odometer_km >= 0)
);

-- 13. Fuel Records Table
CREATE TABLE fuel_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    fuel_date DATE NOT NULL,
    liters DECIMAL(10,2) NOT NULL,
    cost_per_liter DECIMAL(10,2) NOT NULL,
    odometer_km INT NOT NULL,
    station_name VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CHECK (liters > 0),
    CHECK (cost_per_liter > 0),
    CHECK (odometer_km >= 0)
);

-- 14. Insert initial lookup data
INSERT INTO vehicle_types (type_name, description) VALUES
('Lorry', 'Heavy goods vehicle for large shipments'),
('Pickup', 'Light commercial vehicle for small shipments'),
('Trailer', 'Unpowered vehicle pulled by a lorry');

INSERT INTO vehicle_status (status_name, description) VALUES
('Available', 'Vehicle is available for assignments'),
('In Maintenance', 'Vehicle is undergoing maintenance'),
('On Trip', 'Vehicle is currently on a trip'),
('Out of Service', 'Vehicle is not available for any assignments');

INSERT INTO shipment_status (status_name, description) VALUES
('Pending', 'Shipment is awaiting processing'),
('Assigned', 'Shipment has been assigned to a vehicle'),
('In Transit', 'Shipment is on its way'),
('Delivered', 'Shipment has been delivered'),
('Cancelled', 'Shipment has been cancelled');

INSERT INTO maintenance_types (type_name, description) VALUES
('Routine Service', 'Regular maintenance service'),
('Oil Change', 'Engine oil and filter change'),
('Tire Replacement', 'Replacement of worn tires'),
('Brake Service', 'Brake system inspection and repair'),
('Engine Repair', 'Major engine repairs');

INSERT INTO driver_qualifications (qualification_name, description) VALUES
('HGV License', 'License to operate heavy goods vehicles'),
('ADR Certificate', 'Certificate for dangerous goods transport'),
('Defensive Driving', 'Advanced defensive driving course'),
('First Aid', 'First aid certification'),
('Forklift License', 'License to operate forklifts');