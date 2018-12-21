#!/usr/bin/env ruby

require_relative 'abstract_preprocess'

class EpubPreprocess < AbstractPreprocess
    def print_pagebreaker_and_title_with_anchor(title, id)
        # Вставляем заголовок главы книги
        # При этом создается разрыв страницы между главами книги
        print "\n\n"
        print "# " + @section_yaml['title']
        print "\n\n"

        # На уровне начала главы книги создаем якорь, на который
        # можно ссылаться, например, из оглавления книги
        print "<span id='" + @section_yaml['id'] + "'></span>"
    end

    def print_rightalign(text)
        print "<div style='text-align: right'>" + text + "</div>\n"
    end

    def print_divbox_begin
        # Создаем div-блок под ширину страницы epub-файла (c внутренними отступами)
        print "<div style='text-align: right; padding: 0px 5%; border: 1px solid black;'>"
    end

    def print_divbox_lastline_breaker
        # Ничего не пишем, т.к. перевода строки достаточно
    end

    def print_divbox_end
        print "</div>"
    end

    def print_divbox_line_breaker
        print "<br/>"
    end

    def preprocess_divbox!(line)
        # обрезаем символ перевода строки в конце и все пробелы в начале строки
        line.strip!
    end

    def get_underline_replacement
        "<span style='text-decoration: underline'>\\1</span>"
    end

    def postprocess_divbox!(line)
        # Ничего не делаем
    end

    def get_hyperlink_replacement
        # Преобразование ссылок из многостраничного формата в одностраничный формат
        # Примеры:
        # 1) преобразование ссылки на начало главы книги (например, из оглавления):
        #    [text](1-bla-bla-chapter-c01.html) -> [text](#c01)
        # 2) преобразование ссылки внутрь главы книги:
        #    [text](1-bla-bla-chapter-c01.html#p05) -> [text](#c01p05)
        "[\\1](#\\2\\3)"
    end

    def get_anchor_replacement(id)
        # Преобразование разметки с якорем для ссылок из многостраничного формата в одностраничный формат:
        # <a id="p05"></a> -> <span id="c01p05"></span>
        "<span id='" + id + "\\2'></span>"
    end
end

EpubPreprocess.new.main