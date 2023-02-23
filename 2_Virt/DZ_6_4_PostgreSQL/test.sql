SELECT attname, avg_width from (SELECT
    attname,
    avg_width
  FROM
    pg_stats
  WHERE tablename = 'orders') names
JOIN (
  SELECT
    MAX(avg_width) as mw
  FROM
    pg_stats
  where
    tablename = 'orders'
) width ON names.avg_width = width.mw;

-- Задание 3

CREATE TABLE orders_1 ( CHECK (price > 499) ) INHERITS (orders);
CREATE TABLE orders_2 ( CHECK (orders.price <= 499) ) INHERITS (orders);

select * from orders

CREATE OR REPLACE FUNCTION orders_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.price > 499) THEN INSERT INTO orders_1 VALUES (NEW.*);
    ELSIF (NEW.price <= 499) THEN INSERT INTO orders_2 VALUES (NEW.*);
    ELSE 
        RAISE EXCEPTION
  'Price out of range (how did you do this?)';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_orders_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE PROCEDURE measurement_insert_trigger();


CREATE TABLE public.test (
    id integer NOT NULL,
    title character varying(80) UNIQUE NOT NULL,
    price integer DEFAULT 0
);

