-- Example Transaction: Place Order (atomic)

BEGIN;

-- 1. Insert order (total_amount computed in app or via query)
INSERT INTO orders (user_id, restaurant_id, partner_id, total_amount, status)
VALUES (1, 1, NULL, 350.00, 'placed')
RETURNING order_id;

-- Assume returned order_id = X. Insert order items (this will call trigger to decrement stock)
INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
  (X, 2, 1, 150.00),
  (X, 3, 1, 200.00);

-- 3. Create payment record (pending)
INSERT INTO payments (user_id, order_id, amount, mode, status) VALUES (1, X, 350.00, 'card', 'pending');

-- If payment gateway returns success, update payments.status='success' (handled in backend)
COMMIT;
-- On any exception, ROLLBACK;


-- Sample Analytic Queries

-- Top 5 restaurants by revenue (last 30 days)
SELECT r.restaurant_id, r.name, SUM(o.total_amount) AS revenue
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
WHERE o.placed_at >= now() - INTERVAL '30 days' AND o.status <> 'cancelled'
GROUP BY r.restaurant_id, r.name
ORDER BY revenue DESC
LIMIT 5;

-- Driver performance: average rating and completed rides in last 90 days
SELECT d.driver_id, u.name, COALESCE(AVG(rt.score),0) as avg_rating, COUNT(r.ride_id) FILTER (WHERE r.status='completed' AND r.completed_at >= now() - INTERVAL '90 days') as completed_rides
FROM drivers d
JOIN users u ON u.user_id = d.driver_id
LEFT JOIN ratings rt ON rt.driver_id = d.driver_id
LEFT JOIN rides r ON r.driver_id = d.driver_id
GROUP BY d.driver_id, u.name
ORDER BY completed_rides DESC;

-- Fraud detection: users with > X failed payments in last 7 days
SELECT user_id, COUNT(*) as failed_count
FROM payments
WHERE status = 'failed' AND transacted_at >= now() - INTERVAL '7 days'
GROUP BY user_id
HAVING COUNT(*) > 3;
