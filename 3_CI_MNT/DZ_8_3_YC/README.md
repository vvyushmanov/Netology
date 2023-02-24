## Установка стека Clickhouse + Vector + Lighthouse

### Создание инфраструктуры в Yandex Cloud

1. Имя play - Create VMs
2. Хосты: localhost (команды выполняются на контроллинг ноде)
3. Тэги:  vm (можно запустить только создание виртуальных машин)

#### Таски

1. Создание ВМ для Clickhouse
    * Используется кастомный модуль ycc_vm для управления Yandex Cloud
    * Большая часть параметров заданы переменными в `group_vars/all/vars.yml`, токен доступа зашифрован с помощью `ansible-vault`
2. Старт ВМ Clickhouse
3. Аналогичные таски для создания ВМ под Lighthouse и Vector

### Создание динамического inventory

1. Имя: Collect instances
2. Хосты: localhost (команды выполняются на контроллинг ноде)
3. Тэги:  init, full (можно запускать в связке с установкой одного из элементов стека, или запустить установку всех (без создания ВМ))

#### Таски

1. Получить список инстансов YC 
    * Используется консольная команда утилиты yc, вывод в виде YAML файлы
    * Результат (в виде строки) записавается в переменную `yc_instances`
2. Создать переменную `_yc_instances`
    * C помощью фильтра from_yaml строчное содержимое yc_instances записывается в струкрурированную переменную Ансибл
3. Добавление хостов
    * Производится итерация по _yc_instances
    * имя группы соответствует имени виртуальной машины
    * извлекается и записывается в динамический инвентарь IP адрес ноды (доступ по xpath)

### Установка Clickhouse

#### Основной блок

1. Имя play - Install Clickhouse
2. Хосты: clickhouse (получен динамически)
3. Тэги:  `clickhouse`, `full` (можно запустить плэйбук с тэгом `clickhouse`, установится только он)
4. Хэндлеры (выполнятся по завершению всех тасок либо если "дёрнуть" `flush handlers`)
    * Используется плагин `service`, чтобы запустить `systemd` сервис кликхауса

#### Таски

1. Скачивание дистрибутивов кликхауса, с указанием версии, прописанной в `vars`
    * С помощью `with_items` выполняется в цикле, чтобы скачать клиент, сервер и общий пакет
2. Установка пакетов кликхауса с помощью модуля `yum`
    * После установки выполняется оповещение хендлера перезапуска
3. Добавление кастомного конфига (добавление возможности слушать на всех интерфейсах)
    * Используется модуль `templates`, формирующий и копирующий необходимый конфиг
    * Дергается перезапуск сервиса
4. Принудительное выполнение хендлера, с целью запустить сервис в этой точке плэйбука
5. Создание базы данных кликхауса с помощью консольной команды (модуль `command`)
    * Запись результата выполнения команды (exit code) в переменную `create_db`.
    * Если код выхода не 0 и не 82, считать шаг `failed`, если код 0 - `changed`

### Установка Vector

#### Основной блок

1. Имя play - Install Vector
2. Хосты: vector (получен динамически)
3. Тэги:  `vector`, `full` (можно запустить плэйбук с тэгом vector, установится только он)
4. Хэндлеры (выполнятся по завершению всех тасок либо если "дёрнуть" `flush handlers`)
    * Используется плагин `service`, чтобы запустить `systemd` сервис вектора

#### Таски

1. Создание сервис-юзера `vector`, под которым будет работать сервис
2. Создание директории `vector`, в которую будет выполнена установка
    * Директория создаётся по пути `/home/vector/vector`, заданному в переменной `home`
    * Создаётся от пользователя `vector`
3. Скачивание архива с дистрибутивом вектора
4. Распаковка дистрибутива 
    * Параметр `strip-components` позволяет убрать "промежуточную" директорию верхнего уровня, находящуюся в архиве
    * Указаны абсолютные пути, т.к. с относительными модуль выдаёт ошибку
5. Начало блока уставки. Создание симлинка для исполняемого файла
    * Выполняется от `root`
    * Симлинк помещается в директорию `/usr/bin` и ссылается на файл, расположенный в `~/vector/bin`
6. Создание `data` директории
    * Выполняется от `root`
    * Согласно мануалу, дата-директория размещается в `/var/lib/vector`
    * Права на директорию выдаются пользователю `vector`
7. Создание конфигурационной директории в директории `/etc`
    * Путь: `/etc/vector`
8. Cоздание симлинка для файла конфигурации
    * Файл расположен в `~/vector/config`
9. Добавление сервиса в `systemd`
    * Образец сервис-файла прилагается к архиву, расположен в `~/vector/etc`
    * С помощью модуля `file`, с правами `root`, копируется в `/etc/systemd/system`
    * Оповещается хендлер, стартующий сервис

### Установка Nginx (необходим для Lighthouse)

#### Основной блок

1. Имя play - Install Nginx
2. Хосты: lighthouse (получен динамически)
3. Тэги:  `lighthouse`, `full` (можно запустить плэйбук с тэгом lighthouse, установится только он)
4. Хэндлеры (выполнятся по завершению всех тасок либо если "дёрнуть" `flush handlers`)
    * Используется плагин `service`, чтобы запустить `systemd` сервис nginx
    * Также используется модуль `command`, чтобы перезапускать nginx встроенной в него командой

#### Таски

1. Установка `epel`
    * Является необходимым пре-реквизитом
    * Установка с помощью модуля yum
2. Установка `nginx`
    * Вызывается хендлер на перезапуск nginx
3. Создание файла конфигурации 
    * Используется модуль template
    * Вызывается хендлер на перезапуск nginx

### Установка Lighthouse

#### Основной блок

1. Имя play - Install Lighthouse
2. Хосты: lighthouse (получен динамически)
3. Тэги:  `lighthouse`, `full` (можно запустить плэйбук с тэгом lighthouse, установится только он)
4. Хэндлеры (выполнятся по завершению всех тасок либо если "дёрнуть" `flush handlers`)
    * Используется модуль `command`, чтобы перезапускать nginx встроенной в него командой

#### Таски

1. Установка `git`
    * Является необходимым пре-реквизитом
    * Установка с помощью модуля yum
2. Скачивание репозитория `Lighthouse`
    * Используется модуль `git`
    * Расположение репозитория и директория установки заданы с помощью переменных
3. Добавление конфига `Lighthouse` к конфигам `Nginx`
    * Используется модуль template
4. Обновление SELinux свойств директории
    * С помощью модуля `sefcontext` выполняется команда, дающая nginx'у доступ к файлам и директориям по пути, где они расположены