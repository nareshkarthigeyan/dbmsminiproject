-- Create some users
INSERT INTO users (name, phone, email, role, wallet_balance) VALUES
('Alice','+911234567890','alice@example.com','customer',100.00),
('Bob','+911234567891','bob@example.com','driver',0.00),
('Charlie','+911234567892','charlie@rest.com','merchant',0.00),
('Admin','+919876543210','admin@example.com','admin',0.00);

-- Make driver profile for Bob (user_id 2)
INSERT INTO drivers (driver_id, license_no, vehicle_no, rating, status) VALUES (2,'DL-12345','KA01AB1234',4.8,'available');

-- Restaurant owned by Charlie (user_id 3)
INSERT INTO restaurants (owner_id, name, location, cuisine) VALUES (3,'Tasty Corner','MG Road, Bangalore','Indian');

-- Add menu items (restaurant_id likely 1)
INSERT INTO menu_items (restaurant_id, name, description, price, available, stock) VALUES
(1,'Paneer Butter Masala','Creamy paneer curry',180.00,TRUE,10),
(1,'Garlic Naan','Tandoor bread',40.00,TRUE,20),
(1,'Veg Biryani','Aromatic biryani',220.00,TRUE,8);

-- Create a delivery partner
INSERT INTO delivery_partners (name, phone, vehicle_no, status) VALUES ('DeliverySam','+919900112233','KA01XY9999','available');
