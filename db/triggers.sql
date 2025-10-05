-- Triggers that attach to the functions defined in functions.sql

-- Attach driver active rides check
DROP TRIGGER IF EXISTS trg_driver_active_rides ON rides;
CREATE TRIGGER trg_driver_active_rides
    BEFORE INSERT OR UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION fn_check_driver_active_rides();

-- Attach stock decrement trigger
DROP TRIGGER IF EXISTS trg_decrement_stock ON order_items;
CREATE TRIGGER trg_decrement_stock
    BEFORE INSERT ON order_items
    FOR EACH ROW EXECUTE FUNCTION fn_decrement_stock();

-- Attach payment success trigger
DROP TRIGGER IF EXISTS trg_payment_success ON payments;
CREATE TRIGGER trg_payment_success
    AFTER UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION fn_payment_success_update();
