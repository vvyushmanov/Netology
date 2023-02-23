# Домашнее задание к занятию "5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

### Ответ:

1. [Манифест](https://github.com/vvyushmanov/devops-netology/blob/main/Virt/DZ_6_5_Elasticsearch/dockerfile)
2. [Файл конфигурации](https://github.com/vvyushmanov/devops-netology/blob/main/Virt/DZ_6_5_Elasticsearch/config/elasticsearch.yml)
3. [Образ](https://hub.docker.com/r/vyushmanov/elasticsearch/tags)
4. Вывод:



```JSON
    {
  "name" : "netology",
  "cluster_name" : "docker-cluster-netology",
  "cluster_uuid" : "3-tXdtTNTQ-twg1xOigv2w",
  "version" : {
    "number" : "8.6.1",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "180c9830da956993e59e2cd70eb32b5e383ea42c",
    "build_date" : "2023-01-24T21:35:11.506992272Z",
    "build_snapshot" : false,
    "lucene_version" : "9.4.2",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

### Ответ

(для выполнения запросов мной был использован Postman)

`GET localhost:9200/*`
```JSON
{
    "ind-1": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "1",
                "provided_name": "ind-1",
                "creation_date": "1674775162455",
                "number_of_replicas": "0",
                "uuid": "bThdzZpCQr6ryqTxx2b2lg",
                "version": {
                    "created": "8060199"
                }
            }
        }
    },
    "ind-2": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "2",
                "provided_name": "ind-2",
                "creation_date": "1674775209570",
                "number_of_replicas": "1",
                "uuid": "Jzw2Sb2LR--trwetKrmeCA",
                "version": {
                    "created": "8060199"
                }
            }
        }
    },
    "ind-3": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "4",
                "provided_name": "ind-3",
                "creation_date": "1674775246323",
                "number_of_replicas": "2",
                "uuid": "yUh1sDEeSlmJILFDR2e91g",
                "version": {
                    "created": "8060199"
                }
            }
        }
    }
}
```

`GET localhost:9200/_cluster/health`

```json
{
    "cluster_name": "docker-cluster-netology",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 8,
    "active_shards": 8,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 44.44444444444444
}
```

`GET localhost:9200/_cat/indices`

```
green  open ind-1 nw9D8W_LTeiCuIZruQPMsw 1 0 0 0 225b 225b
yellow open ind-3 pR4pT-AITRqVVaBDBHx3Aw 4 2 0 0 413b 413b
yellow open ind-2 UqrEnRoCS_2NS3MZ15_AQg 2 1 0 0 413b 413b
```

Часть индексов и кластер находятся в состоянии Yellow потому, что в кластере всего 1 нода, и невозможно заассайнить все шарды и их реплики.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

### Ответ

(запросы выполнялись в Postman)

1. PUT localhost:9200/_snapshot/netology_backup
```json
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshots"
  }
}
```

```json
{
    "acknowledged": true
}
```

2. GET localhost:9200/_all
```json
{
    "test": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "1",
                "provided_name": "test",
                "creation_date": "1674779700509",
                "number_of_replicas": "0",
                "uuid": "NKuSep9gRU-ke2ivpAc4pQ",
                "version": {
                    "created": "8060199"
                }
            }
        }
    }
}
```

3. PUT localhost:9200/_snapshot/netology_backup/new_snapshot?wait_for_completion=true
```json
{
    "snapshot": {
        "snapshot": "new_snapshot",
        "uuid": "BbFttboqRpGpBgDbJ-dBKQ",
        "repository": "netology_backup",
        "version_id": 8060199,
        "version": "8.6.1",
        "indices": [
            ".geoip_databases",
            "test"
        ],
        "data_streams": [],
        "include_global_state": true,
        "state": "SUCCESS",
        "start_time": "2023-01-27T00:52:10.313Z",
        "start_time_in_millis": 1674780730313,
        "end_time": "2023-01-27T00:52:11.914Z",
        "end_time_in_millis": 1674780731914,
        "duration_in_millis": 1601,
        "failures": [],
        "shards": {
            "total": 2,
            "failed": 0,
            "successful": 2
        },
        "feature_states": [
            {
                "feature_name": "geoip",
                "indices": [
                    ".geoip_databases"
                ]
            }
        ]
    }
}
```

4. Список файлов (директория монтирована с хост-машины, см. [docker-copmose.yml](https://github.com/vvyushmanov/devops-netology/blob/main/Virt/DZ_6_5_Elasticsearch/docker-compose.yml)):

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/Virt/DZ_6_5_Elasticsearch on main]
$ ll ./snapshots                                                                                ✹ ✭
total 36K
-rw-r--r-- 1 vyushmanov vyushmanov  845 Jan 27 04:52 index-0
-rw-r--r-- 1 vyushmanov vyushmanov    8 Jan 27 04:52 index.latest
drwxr-xr-x 4 vyushmanov vyushmanov 4.0K Jan 27 04:52 indices
-rw-r--r-- 1 vyushmanov vyushmanov  19K Jan 27 04:52 meta-BbFttboqRpGpBgDbJ-dBKQ.dat
-rw-r--r-- 1 vyushmanov vyushmanov  351 Jan 27 04:52 snap-BbFttboqRpGpBgDbJ-dBKQ.dat
```

5. Новый индекс test-2:
```json
{
    "test-2": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "1",
                "provided_name": "test-2",
                "creation_date": "1674781156675",
                "number_of_replicas": "0",
                "uuid": "iLI1Nk9EQQColNFOntSQrg",
                "version": {
                    "created": "8060199"
                }
            }
        }
    }
}
```

6. Восстановление индекса:
* Поскольку в задании нет прямого указания на необходимость удаления нового индекса, запрос `DELETE localhost:9200/test` не выполнялся

```api
POST localhost:9200/_snapshot/netology_backup/new_snapshot/_restore
    {
    "indices": "*"
    }
```
Список индексов:
```json
{
    "test": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "1",
                "provided_name": "test",
                "creation_date": "1674780637008",
                "number_of_replicas": "0",
                "uuid": "4iCM9vklTAiHC-uUpH3tTg",
                "version": {
                    "created": "8060199"
                }
            }
        }
    },
    "test-2": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "1",
                "provided_name": "test-2",
                "creation_date": "1674781156675",
                "number_of_replicas": "0",
                "uuid": "iLI1Nk9EQQColNFOntSQrg",
                "version": {
                    "created": "8060199"
                }
            }
        }
    }
}
```