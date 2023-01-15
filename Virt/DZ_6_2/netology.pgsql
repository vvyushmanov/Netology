CREATE USER test_admin_user;
CREATE DATABASE test_db;

CREATE TABLE orders (
    "id" SERIAL PRIMARY KEY,
    "наименование" VARCHAR (50),
    "цена" INT
    );
CREATE TABLE clients (
    "id" SERIAL PRIMARY KEY,
    "фамилия" VARCHAR (50),
    "страна проживания" VARCHAR (50),
    "заказ" INT,
    FOREIGN KEY ("заказ") REFERENCES orders (id)
    );
CREATE INDEX countries ON clients ("страна проживания");

GRANT ALL ON clients, orders TO test_admin_user;

CREATE USER test_simple_user;

GRANT SELECT, INSERT, UPDATE, DELETE ON clients, orders TO test_simple_user;

SELECT table_name, grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name IN ('clients', 'orders') AND table_catalog='test_db' ORDER BY table_name, grantee ASC;

////////

INSERT INTO orders (наименование, цена) VALUES ('Шоколад', 10);
INSERT INTO orders (наименование, цена) VALUES ('Принтер', 3000);
INSERT INTO orders (наименование, цена) VALUES ('Книга', 500);
INSERT INTO orders (наименование, цена) VALUES ('Монитор', 7000);
INSERT INTO orders (наименование, цена) VALUES ('Гитара', 4000);

INSERT INTO clients (фамилия, "страна проживания") VALUES ('Иванов Иван Иванович', 'USA');
INSERT INTO clients (фамилия, "страна проживания") VALUES ('Петров Петр Петрович', 'Canada');
INSERT INTO clients (фамилия, "страна проживания") VALUES ('Иоганн Себастьян Бах', 'Japan');
INSERT INTO clients (фамилия, "страна проживания") VALUES ('Ронни Джеймс Дио', 'Russia');
INSERT INTO clients (фамилия, "страна проживания") VALUES ('Ritchie Blackmore', 'Russia');

SELECT COUNT (*) FROM orders;
SELECT COUNT (*) FROM clients;

///////////////////

UPDATE clients SET заказ = (select id from orders where наименование='Книга') WHERE фамилия='Иванов Иван Иванович';
UPDATE clients SET заказ = (select id from orders where наименование='Монитор') WHERE фамилия='Петров Петр Петрович';
UPDATE clients SET заказ = (select id from orders where наименование='Гитара') WHERE фамилия='Иоганн Себастьян Бах';

SELECT фамилия FROM clients WHERE заказ is not null;


///////////////

EXPLAIN SELECT фамилия FROM clients WHERE заказ is not null;
