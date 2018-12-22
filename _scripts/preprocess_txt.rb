#!/usr/bin/env ruby

require_relative 'abstract_preprocess'

class TxtPreprocess < AbstractPreprocess
    TXT_LINE_LENGTH = 70

    def print_pagebreaker_and_title_with_anchor(title, id)
        # Вставляем заголовок главы книги
        print "\n\n"
        print "-" * 2
        print "\n"
        print title
        print "\n"
        print "-" * 2
        print "\n\n"
    end

    def print_rightalign(text)
        print "\n"
        print text.rjust(TXT_LINE_LENGTH, " ") # доколотить строку пробелами слева до длины TXT_LINE_LENGTH
        print "\n"
    end

    def print_divbox_begin
        print "*" * TXT_LINE_LENGTH
        print "\n"
    end

    def print_divbox_lastline_breaker
        ""
    end

    def print_divbox_end
        print "*" * TXT_LINE_LENGTH
        print "\n"
    end

    def print_divbox_line_breaker
        ""
    end

    def preprocess_divbox!(line)
        line.strip!
    end

    def get_underline_replacement
        "*\\1*"
    end

    def postprocess_divbox!(line)
        # Хотел сделать просто line.rjust!, но такого метода нет, поэтому
        # уже через line.sub! меняю содержимое в самой переменной line
        line.sub!(/^.*$/, line.rjust(TXT_LINE_LENGTH, " ") + "\n") # доколотить строку пробелами слева до длины TXT_LINE_LENGTH
    end

    def get_hyperlink_replacement
        "*\\1*"
    end

    def get_anchor_replacement(id)
        ""
    end

    def print_cover_and_title_pages(main_yaml)
        # Обложки в txt-формате быть не может
        # Поэтому просто делаю титульную страницу
        print "\n\n"
        print "-" * 2
        print "\n"
        print main_yaml['title']
        print "\n"
        print "-" * 2
        print "\n\n"
        print main_yaml['subtitle']
        print "\n\n"
        print "by"
        print "\n\n"
        print main_yaml['author']
        print "\n\n"
        print main_yaml['publisher']
        print "\n\n"
        print main_yaml['date'].to_s
        print "\n\n"
    end
end

TxtPreprocess.new.main