# Домашнее задание к занятию "6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

### Ответ

Все `data_source` перечислены [здесь](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L419)

Все `resource` перечислены [здесь](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L944)


1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя? 


### Ответ

1) Параметр конфликтует с параметром `name_prefix`
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L88


2) Судя по всему, данное ограничение было убрано в новой версии, для параметра `name` не задан параметр `ValidateFunc`. Так, например, для параметра `visibility_timeout_seconds` задано ограничение диапазона значений от 0 до 43200
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L150


3) Регулярное выражение также было убрано из проверки. Проверка имела бы вид `validation.StringMatch` (метод StringMatch пакета validation).
Например, это реализовано в текущей версии `iam`, имя ресурса должно соответствовать регулярному выражению `^[\w+=,.@-]*$`
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/iam/validate.go#L19

Или, например, для ресурса `AlternateContact`, где для параметра `email_address` используется регулярное выражение `[\w+=,.-]+@[\w.-]+\.[\w]+`, позволяющее проверить, вводится ли валидный email адрес
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/account/alternate_contact.go#L53

