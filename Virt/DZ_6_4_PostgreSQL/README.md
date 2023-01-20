# Домашнее задание к занятию "9. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
```yaml
version: "3.9"
services:
  postgres:
    container_name: postgresql
    image: postgres:13
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_HOST_AUTH_METHOD=trust
    volumes:
      - ./data:/var/lib/postgresql/data
    restart: always
```

Подключитесь к БД PostgreSQL используя `psql`.

```shell
docker exec -it -u postgres postgresql psql
```

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

```sql
\l[+]   [PATTERN]      list databases
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
\dt[S+] [PATTERN]      list tables
\d[S+]  NAME           describe table, view, sequence, or index
\q                     quit psql
```

## Задача 2

Используя `psql` создайте БД `test_database`.

```sql
CREATE DATABASE test_database;
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

```shell
postgres@aee24fca9274:~/data$ psql test_database < test_dump.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

```sql
postgres=# \c test_database 
You are now connected to database "test_database" as user "postgres".
test_database=# ANALYZE;
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sql
test_database=# SELECT attname, avg_width from (SELECT
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
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```sql

BEGIN;
CREATE TABLE orders_1 ( CHECK (price > 499) ) INHERITS (orders);
CREATE TABLE orders_2 ( CHECK (price <= 499) ) INHERITS (orders);
INSERT INTO orders_1 SELECT * FROM orders WHERE price > 499;
DELETE FROM orders WHERE price > 499;
INSERT INTO orders_1 SELECT * FROM orders WHERE price <= 499;
DELETE FROM orders WHERE price <= 499;
COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```sql
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
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```shell
## запустить bash в контейнере
postgres@aee24fca9274:~/data$ pg_dump test_database > backup.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

В файле backup.sql необходимо добавить constraint UNIQUE в запрос, создающий таблицу orders:

```sql
--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) UNIQUE NOT NULL,
    price integer DEFAULT 0
);


ALTER TABLE public.orders OWNER TO postgres;
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
