## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```yml
version: "3.9"
services:
  postgres:
    image: postgres:12
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_HOST_AUTH_METHOD=trust
    volumes:
      - ./data:/var/lib/postgresql/data
      - ./backup:/var/backup
    restart: always
```
```shell
$ docker-compose -f postgres.yml up --detach
$ docker exec -it -u postgres dz_6_2_postgres_1 psql
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Команды:
```sql
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
```

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

```shell
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
```

```shell
test_db=# \d orders
                                      Table "public.orders"
    Column    |         Type          | Collation | Nullable |              Default               
--------------+-----------------------+-----------+----------+------------------------------------
 id           | integer               |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying(50) |           |          | 
 цена         | integer               |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# \d clients
                                         Table "public.clients"
      Column       |         Type          | Collation | Nullable |               Default               
-------------------+-----------------------+-----------+----------+-------------------------------------
 id                | integer               |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying(50) |           |          | 
 страна проживания | character varying(50) |           |          | 
 заказ             | integer               |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "countries" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```

```sql
SELECT table_name, grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name IN ('clients', 'orders') AND table_catalog='test_db' 
ORDER BY table_name, grantee ASC;
```
```
36 rows returned
table_name
name
grantee
name
privilege_type
character varying
1	clients	postgres	INSERT
2	clients	postgres	TRIGGER
3	clients	postgres	REFERENCES
4	clients	postgres	TRUNCATE
5	clients	postgres	DELETE
6	clients	postgres	UPDATE
7	clients	postgres	SELECT
8	clients	test_admin_user	INSERT
9	clients	test_admin_user	TRIGGER
10	clients	test_admin_user	REFERENCES
11	clients	test_admin_user	TRUNCATE
12	clients	test_admin_user	DELETE
13	clients	test_admin_user	UPDATE
14	clients	test_admin_user	SELECT
15	clients	test_simple_user	DELETE
16	clients	test_simple_user	INSERT
17	clients	test_simple_user	SELECT
18	clients	test_simple_user	UPDATE
19	orders	postgres	INSERT
20	orders	postgres	TRIGGER
21	orders	postgres	REFERENCES
22	orders	postgres	TRUNCATE
23	orders	postgres	DELETE
24	orders	postgres	UPDATE
25	orders	postgres	SELECT
26	orders	test_admin_user	INSERT
27	orders	test_admin_user	TRIGGER
28	orders	test_admin_user	REFERENCES
29	orders	test_admin_user	TRUNCATE
30	orders	test_admin_user	DELETE
31	orders	test_admin_user	UPDATE
32	orders	test_admin_user	SELECT
33	orders	test_simple_user	DELETE
34	orders	test_simple_user	SELECT
35	orders	test_simple_user	UPDATE
36	orders	test_simple_user	INSERT
```


## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```sql
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
 count 
-------
     5
(1 row)

SELECT COUNT (*) FROM clients;
 count 
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Ответ:

(Поскольку в рамках данной задачи наименования заказов не повторяются, для получения ID заказа можно использовать подзапрос)

```sql
UPDATE clients SET заказ = (select id from orders where наименование='Книга') WHERE фамилия='Иванов Иван Иванович';
UPDATE clients SET заказ = (select id from orders where наименование='Монитор') WHERE фамилия='Петров Петр Петрович';
UPDATE clients SET заказ = (select id from orders where наименование='Гитара') WHERE фамилия='Иоганн Себастьян Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```sql
SELECT фамилия FROM clients WHERE заказ is not null;
       фамилия        
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)
```
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
