-- ========= Function: prevent multiple active rides per driver =========
CREATE OR REPLACE FUNCTION fn_check_driver_active_rides() RETURNS TRIGGER AS $$
DECLARE
    active_count INT;
BEGIN
    IF NEW.driver_id IS NULL THEN
        RETURN NEW; -- nothing to check
    END IF;

    -- Only check when inserting a ride with status assigned/ongoing or updating to assigned/ongoing
    IF TG_OP = 'INSERT' THEN
        IF NEW.status IN ('assigned','ongoing') THEN
            SELECT COUNT(*) INTO active_count FROM rides WHERE driver_id = NEW.driver_id AND status IN ('assigned','ongoing');
            IF active_count > 0 THEN
                RAISE EXCEPTION 'Driver % already has an active ride', NEW.driver_id;
            END IF;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.driver_id IS NOT NULL AND NEW.status IN ('assigned','ongoing') THEN
            SELECT COUNT(*) INTO active_count FROM rides WHERE driver_id = NEW.driver_id AND status IN ('assigned','ongoing') AND ride_id <> NEW.ride_id;
            IF active_count > 0 THEN
                RAISE EXCEPTION 'Driver % already has an active ride', NEW.driver_id;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========= Function: decrement stock on order_item insert =========
CREATE OR REPLACE FUNCTION fn_decrement_stock() RETURNS TRIGGER AS $$
DECLARE
    current_stock INT;
BEGIN
    SELECT stock INTO current_stock FROM menu_items WHERE item_id = NEW.item_id FOR UPDATE;

    IF current_stock IS NOT NULL THEN
        IF current_stock < NEW.quantity THEN
            RAISE EXCEPTION 'Insufficient stock for item %', NEW.item_id;
        END IF;
        UPDATE menu_items SET stock = stock - NEW.quantity WHERE item_id = NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========= Function: handle payment success =========
CREATE OR REPLACE FUNCTION fn_payment_success_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF OLD.status <> 'success' AND NEW.status = 'success' THEN
            IF NEW.order_id IS NOT NULL THEN
                UPDATE orders SET status = 'placed' WHERE order_id = NEW.order_id; -- ensure placed
            ELSIF NEW.ride_id IS NOT NULL THEN
                UPDATE rides SET status = 'assigned' WHERE ride_id = NEW.ride_id;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========= Function: calculate merchant revenue =========
CREATE OR REPLACE FUNCTION fn_merchant_revenue(p_restaurant_id INT, p_from TIMESTAMP WITH TIME ZONE, p_to TIMESTAMP WITH TIME ZONE)
RETURNS TABLE(order_count INT, total_revenue NUMERIC, avg_order_value NUMERIC) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(o.order_id)::INT,
           COALESCE(SUM(o.total_amount),0)::NUMERIC,
           CASE WHEN COUNT(o.order_id) = 0 THEN 0 ELSE COALESCE(SUM(o.total_amount),0)/COUNT(o.order_id) END
    FROM orders o
    WHERE o.restaurant_id = p_restaurant_id
      AND o.placed_at >= p_from
      AND o.placed_at < p_to
      AND o.status <> 'cancelled';
END;
$$;
