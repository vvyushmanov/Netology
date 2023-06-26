# Netology
Learning DEVOPS stuff


1. По умолчанию системе выделено 2 ядра ЦПУ, 1 GB оперативной памяти и 64GB дискового пространства.
2. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?
   * Добавить в Vagrantfile следующий фрагмент:

   
            config.vm.provider "virtualbox" do |v|
              v.memory = 2048 # выделить 2ГБ оперативной памяти
              v.cpus = 4 # выделить 4 ядра ЦПУ
            end

3. Ознакомиться с разделами man bash, почитать о настройках самого bash:

* какой переменной можно задать длину журнала history, и на какой строчке manual это описывается?
  * Переменная HISTFILESIZE, строка 909
* что делает директива ignoreboth в bash?
  * При заполнении history игнорирует строки, начинающиеся с пробела, и строки, являющиеся дубликатами ранее введённых.

4.В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?
* Фигурные скобки используются для задания списка значений, которые необходимо "раскрыть" в пределах выполняемой функции, в основном, с целью сокращения (например, при создании или удалении ряда файлов с одинаковой общей частью названия)
* Описано на строке 294 мануала

5. С учётом ответа на предыдущий вопрос, как создать однократным вызовом touch 100000 файлов? Получится ли аналогичным образом создать 300000? Если нет, то почему?
* `touch filename{1..100000}`
* Не получится, так как будет превышен лимит длины аргументов командной строки, bash выведет сообщение об ошибке `-bash: /usr/bin/touch: Argument list too long`
6. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]
* [[ выражение ]] выполняет проверку заданных условий и возвращает 0 или 1 в зависимости от того, успешно ли выполнена команда.
* Соответственно, [[ -d /tmp ]] проверяет, существует ли директория /tmp - если да, возвращает 0 (успешный код выхода), если нет - 1 (соответственно, неуспешный код)
7. Добавить расположение для для bash:
    
        mkdir /tmp/new_path_directory/ 
        sudo cp /bin/bash /tmp/new_path_directory/
        export PATH=/tmp/new_path_directory:$PATH
8. Чем отличается планирование команд с помощью batch и at?
* at выполняет команды в строго заданное время
* batch выполняет команды, когда средняя нагрузка системы падает ниже 1.5