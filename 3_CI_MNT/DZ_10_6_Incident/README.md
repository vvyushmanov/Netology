# Домашнее задание к занятию 17 «Инцидент-менеджмент»

## Основная часть

Составьте постмортем на основе реального сбоя системы GitHub в 2018 году.

Информация о сбое: 

* [в виде краткой выжимки на русском языке](https://habr.com/ru/post/427301/);
* [развёрнуто на английском языке](https://github.blog/2018-10-30-oct21-post-incident-analysis/).

## Постмортем

### Краткое описание инцидента

В 22:52 (21.10) по UTC на нескольких сервисах GitHub.com пострадали несколько сетевых разделов и последующим сбоем базы данных, что привело к появлению непоследовательной информации на веб-сайте.
В результате этого, часть сервисов была недоступна.
Через 24 часа 11 минут был восстановлен бэкап базы данных, переписана конфигурация, и сервисы были восстановлены.

### Причина инцидента

Некорректная топология репликации базы данных привела к тому, что при кратковременном отключении репликация данных рассинхронизировалась из-за сильных задержек.

### Воздействие

В результате инцидента, пользователи не могли использовать вебхуки и сохранять страницы GitHub, некоторые данные были неконсистентны.

### Обнаружение

После появления многочисленных алертов в системе мониторинга, команда дежурных инженеров начала первичное расследование, позже проблема была эскалирована, и ей присвоен статус "красный".

### Реакция

Ответственные разработчики устранили инцидент за 24 часа 11 минут

### Восстановление

2018 October 22 06:51 UTC
Был восстановлен бэкап базы данных, переписана конфигурация. Часть данных из очереди была восстановлена вручную, с проверкой актуальности.

### Таймлайн

21/10 22:52 - Оркестратор, отвечающий за выбор основных узлов, начал процесс переизбрания. Поступила часть данных, которая не была реплицирована вовремя.

21/10 22:54 - Система мониторинга начала присылась оповещения об ошибках, АПИ оркестратора показал некорректно софрмировавшуюся топологию распределённой базы данных.

21/10 23:07 - Заблокирован инструмент деплоя, чтобы предотвратить изменений. Присвоен статус "желтый". Далее присоединился координатор, изменивший статус на "красный"

21/10 23:13 - Стало понятно, что затронуты многие кластеры. Было принято решение, что основная задача - сохранить все данные пользователей, скопившиеся за период рассинхронизации, также стало очевидно, что нужно пересобрать топологию вручную.

21/10 23:19 - Стало очевидно, что необхоимо остановить задачи, пишущие метаданные. Было принято решение о частичной деградации сервиса в угоду сохранению данных пользователей.

22/10 00:05 - Начата разработка плана устранения неконсистентности и failover-процедур MySQL.

22/10 00:41 - Начат процесс восстановления из бэкапа под наблюдением инженеров. Исследуются пути ускорения процесса.

22/10 06:51 - Часть кластеров восстановилась, началась репликация. Это вызвало серьёзную нагрузку на сеть и замедление загрузки страниц.

22/10 07:46 - Написон блог-пост с объяснением ситуации.

22/10 11:12 - Все базы данных на восточном побережье восстановлены. Процесс восстановления занимает больше времени, чем ожидалось, в силу огромного количества read-операций.

22/10 13:15 - Пик трафика на ГитХаб (начался рабочий день у большинства пользователей). Благодаря дополнительным узлам, нагрузку удалось распределить, и восстановление начало догонять до текущего момента.

22/10 16:24 - Как только реплики синхронизировались, был осуществлен возврат к оригинальной топологии. На случай непредвиденных последствий, оставлен статус "красный".

22/10 16:45 - Обрботаны все находившиеся в очереди вебхуки (в т.ч. с увеличением времени жизни для истекших)

22/10 23:03 - Все ожидающие вебхуки и страницы обработаны, работа сервиса полностью восстановлена.

### Последующие действия

* Произведена ручная проверка неконсистентных данных, их индивидуальная обработка в зависимости от необходимости
* Проработка более прозрачного информирования на случай будущих инцидентов
* Различные технические инициативы, такие, как:
  * Реконфигурация Оркестратора для предотвращения некорректных топологий
  * Новый механизм статус-репортинга, позволяющий отслеживать компоненты в отдельности
  * Ускорена кампания по переходу на N+1 конфигурацию избыточности
  * Более тщательный подход к тестированию предположений
