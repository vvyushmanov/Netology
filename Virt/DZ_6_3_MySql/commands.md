```shell
# Задание 1
$ docker-compose -f mysql.yml up --detach

$ docker exec -it -u root mysql bash
$ mysqladmin -u root -pnetology create test_db
$ docker exec -i mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" mysql' < test_dump.sql

$ docker exec -it -u root mysql mysql -p"netology" test_db


mysql> \s
--------------
mysql  Ver 8.0.32 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          24
Current database:       test_db
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.32 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 28 min 14 sec

Threads: 2  Questions: 242  Slow queries: 0  Opens: 315  Flush tables: 3  Open tables: 232  Queries per second avg: 0.142
--------------

show tables








```