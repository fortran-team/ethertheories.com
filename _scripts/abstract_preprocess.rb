#!/usr/bin/env ruby

require 'yaml'

class AbstractPreprocess
    def main
        # Данный скрипт принимает на вход файл настроек jekyll (_config.yml) и
        # файлы глав книги sections/*md. Все эти файлы объединяются в один md-файл
        # книги по следующему принципу:
        # 1) файл _config.yml становится хедером итогового md-файла
        # 2) у файлов глав книги хедеры удаляются, но данные этих хедеров применяются,
        #    чтобы создать правильное отделение глав книги в итоговом документе друг
        #    от друга (например, добавление заголовков глав, разрывы страниц и т.д.)
        # 3) контент файлов глав книги добавляется в итоговый md-файл книги практически
        #    без изменений. Хотя небольшое доп.форматирование допустимо в коде данного
        #    скрипта

        @mainyamldone = false # флаг завершения обработки файла _config.yml
        @inyaml = false # флаг нахождения потока ввода в хедере md-файла или в _config.yml
        @inbox = false # флаг нахождения потока ввода в теле md-файла, а точнее в блоке <div class="box">...</div>
        @firstline_inbox = nil # флаг, обозначающий, что мы перешли к обработке первой строки текста в html-блоке <div class="box">...</div>
        @yaml_block = "" # данные хедера md-файла или _config.yml в виде строки текста
        @main_yaml = nil # данные хедера файла _config.yml в виде объекта YAML (см. модуль 'yaml')
        @section_yaml = nil # данные хедера md-файла в виде объекта YAML (см. модуль 'yaml')

        # В виду того, что на входе скрипта только файлы, то их обработку проще
        # всего делать через поток ввода ARGF, который уже объединил все эти
        # файлы в один и мы можем читать из этого потока, попутно обрабатывая
        # все строки
        ARGF.each_with_index do |line, idx| # FIXME индекс idx не используем
            if /^---\s*$/.match(line) # вход или выход из YAML-блока в хедере md-файла или в _config.yml
                # Печать в стандартный поток вывода строк YAML-блока из файла _config.yml (указанное условие
                # печати позволяет не печатать строки из YAML-блоков в хедерах md-файлов глав книги)
                print line unless @mainyamldone
                @inyaml = !@inyaml # отмечаем вход или выход из YAML-блока
                if @inyaml # если мы находимся в YAML-блоке, то
                    # все его строки собираем в переменной @yaml_block
                    @yaml_block = line + "\n"
                else # если мы выходим из YAML-блока, то
                    # последнюю его строку "---" также помещаем в переменную @yaml_block
                    @yaml_block = @yaml_block + line + "\n"
                    if @main_yaml.nil? # если мы обрабатывали главный YAML-блок из файла _config.yml, то
                        @main_yaml = YAML.load(@yaml_block) # превращаем эти данные в объект
                        # Печать обложки и титульной страницы, если в этом есть необходимость
                        print_cover_and_title_pages(@main_yaml)
                        # Устанавливаем флаг в положение, сигнализирующее, что мы
                        # завершили обработку YAML-блока из файла _config.yml
                        @mainyamldone = true
                    else # если мы обрабатывали YAML-блок из хедера какого-либо md-файла главы книги, то
                        @section_yaml = YAML.load(@yaml_block) # превращаем эти данные в объект
                        print_pagebreaker_and_title_with_anchor(@section_yaml['title'], @section_yaml['id'])
                    end
                end
            elsif @inyaml # если мы находимся в YAML-блоке, то
                print line unless @mainyamldone # в поток вывода отправляем YAML-блок только из файла _config.yml
                @yaml_block = @yaml_block + line + "\n" # но данные YAML-блока собираем в любом случае
            else # если мы находимся в теле md-файла главы книги, то
                # handle catalog-card boxes
                if match = /<p class=(['"])right\1>(.*?)<\/p>/.match(line)
                    # Если встречаем такой блок разметки:
                    #   текст 1
                    #   <p class="right">текст 2</p>
                    #   текст 3
                    # то берем "текст 2" и оформляем его в другом формате
                    quote, text = match.captures
                    print_rightalign(text)
                elsif /<div class=(['"])box\1>/.match(line)
                    # Если встречаем такой блок разметки:
                    #   текст 1
                    #   <div class="box">
                    #       текст 2
                    #   </div>
                    #   текст 3
                    # то берем "текст 2" и оформляем его в другом формате
                    @inbox = true # отмечаем, что мы вошли в <div class="box"> и со следующей строки пойдет "текст 2"
                    # Создаем блок с рамкой под ширину страницы документа (c внутренними отступами)
                    print_divbox_begin
                    print "\n"
                    @firstline_inbox = true
                elsif /<\/div>/.match(line) && @inbox
                    @inbox = false # отмечаем, что мы вышли из <div class="box">...</div>
                    unless @firstline_inbox # если обрабатываем не первую строку текста в html-блоке <div class="box">...</div>, то
                        # Завершаем последнюю строку текста
                        print_divbox_lastline_breaker
                        print "\n"
                    end
                    # Завершаем div-box-блок
                    print_divbox_end
                    print "\n"
                elsif @inbox # обработка текста в html-блоке <div class="box">...</div>
                    unless @firstline_inbox # если обрабатываем не первую строку текста в html-блоке <div class="box">...</div>, то
                        # Завершаем предыдущую строку текста
                        print_divbox_line_breaker
                        print "\n"
                    end
                    preprocess_divbox!(line)
                    # Текст в виде *текст* делаем подчеркнутым
                    # Нужно помнить, что открывающую и закрывающую звездочки для обозначения нашего желания подчеркнуть
                    # текст в генерируемом документе надо ставить в одной и той же строке текста md-файла главы книги
                    line.gsub!(/\*(.+?)\*/, get_underline_replacement)
                    postprocess_divbox!(line)
                    print line # выводим текстовую строку из html-блока <div class="box">...</div> после ее обработки
                    @firstline_inbox = false
                elsif !@section_yaml.nil?
                    # Делаем преобразование ссылок из многостраничного md-формата в другой формат
                    # Должно работать и для нескольких ссылок в одной строке
                    # 1) Тут описано преобразование ссылок на начало глав книги (например, из оглавления):
                    #    [text](1-bla-bla-chapter-c01.html) -> see get_hyperlink_replacement
                    # 2) Тут описано преобразование ссылок внутрь глав книги:
                    #    [text](1-bla-bla-chapter-c01.html#p05) -> see get_hyperlink_replacement
                    line.gsub!(/\[([^\]]*?)\]\(.*?chapter-(.+?)\.html(?:#(.+?))?\)/, get_hyperlink_replacement)

                    # Делаем преобразование разметки с якорем для ссылок из многостраничного md-формата в другой формат:
                    # <a id="p05"></a> -> see get_anchor_replacement
                    # Должно работать и для нескольких якорей в одной строке, но лучше будем делать так:
                    #   какой-то текст
                    #   <a id="p05"></a>
                    #   другой какой-то текст
                    line.gsub!(/<a id=(['"])(.+?)\1><\/a>/, get_anchor_replacement(@section_yaml['id']))

                    print line
                else
                    # Сюда попасть можем только сразу после обработки полей из файла _config.yml и только если
                    # в этом файле под набором полей после закрывающей строки "---" будет какое-то содержимое
                    print line
                end
            end
        end
    end

    private
    # Ниже идут методы, которые нужно будет реализовать в дочерних классах согласно паттерну "шаблонный метод"

    def print_pagebreaker_and_title_with_anchor(title, id)
        raise NotImplementedError
    end

    def print_rightalign(text)
        raise NotImplementedError
    end

    def print_divbox_begin
        raise NotImplementedError
    end

    def print_divbox_lastline_breaker
        raise NotImplementedError
    end

    def print_divbox_end
        raise NotImplementedError
    end

    def print_divbox_line_breaker
        raise NotImplementedError
    end

    def preprocess_divbox!(line)
        raise NotImplementedError
    end

    def get_underline_replacement
        raise NotImplementedError
    end

    def postprocess_divbox!(line)
        raise NotImplementedError
    end

    def get_hyperlink_replacement
        raise NotImplementedError
    end

    def get_anchor_replacement(id)
        raise NotImplementedError
    end

    def print_cover_and_title_pages(main_yaml)
        # По умолчанию:
        #   Не требуется никаких действий, т.к. pandoc сам вставит обложку и создаст титульную страницу
    end
end