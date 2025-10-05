-- Drop if exists (safe local dev)
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
SET search_path = public;

-- USERS (customers + merchants + drivers as roles)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE,
    address TEXT,
    role TEXT NOT NULL CHECK (role IN ('customer','driver','merchant','admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    wallet_balance NUMERIC(12,2) DEFAULT 0.00
);

-- DRIVERS (profile details)
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    license_no TEXT UNIQUE NOT NULL,
    vehicle_no TEXT NOT NULL,
    rating NUMERIC(3,2) DEFAULT 5.00,
    status TEXT NOT NULL CHECK (status IN ('available','busy','offline')) DEFAULT 'offline'
);

-- RESTAURANTS (merchants will also have users entry with role=merchant)
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    cuisine TEXT,
    rating NUMERIC(3,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- MENU ITEMS
CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    available BOOLEAN DEFAULT TRUE,
    stock INT DEFAULT NULL -- optional; NULL means unlimited
);

-- DELIVERY PARTNERS (optional, can be internal or external)
CREATE TABLE delivery_partners (
    partner_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    vehicle_no TEXT,
    status TEXT NOT NULL CHECK (status IN ('available','busy','offline')) DEFAULT 'available'
);

-- RIDES
CREATE TABLE rides (
    ride_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    driver_id INT REFERENCES drivers(driver_id),
    source TEXT NOT NULL,
    destination TEXT NOT NULL,
    fare NUMERIC(10,2) NOT NULL CHECK (fare >= 0),
    status TEXT NOT NULL CHECK (status IN ('requested','assigned','ongoing','completed','cancelled')) DEFAULT 'requested',
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ORDERS
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE SET NULL,
    partner_id INT REFERENCES delivery_partners(partner_id), -- nullable if in-house
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('placed','preparing','picked_up','delivered','cancelled','refunded')) DEFAULT 'placed',
    placed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    delivered_at TIMESTAMP WITH TIME ZONE
);

-- ORDER ITEMS (many-to-many)
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    item_id INT NOT NULL REFERENCES menu_items(item_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- PAYMENTS (link to order OR ride)
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    ride_id INT REFERENCES rides(ride_id),
    order_id INT REFERENCES orders(order_id),
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    mode TEXT NOT NULL CHECK (mode IN ('card','upi','cash','wallet')),
    status TEXT NOT NULL CHECK (status IN ('pending','success','failed','refunded')) DEFAULT 'pending',
    transacted_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- RATINGS (generic ratings for drivers/restaurants/orders)
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    driver_id INT REFERENCES drivers(driver_id),
    restaurant_id INT REFERENCES restaurants(restaurant_id),
    order_id INT REFERENCES orders(order_id),
    ride_id INT REFERENCES rides(ride_id),
    score INT NOT NULL CHECK (score BETWEEN 1 AND 5),
    comment TEXT,
    rated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes for common queries
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_rides_status ON rides(status);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_payments_status ON payments(status);
