#!/usr/bin/env ruby

require_relative 'abstract_preprocess'

class PdfPreprocess < AbstractPreprocess
    def print_pagebreaker_and_title_with_anchor(title, id)
        print "\n\n"
        print "\\newpage" # создаем разрыв страницы между главами книги (latex-формат)
        print "\n"
        # На уровне начала главы книги создаем якорь, на который можно
        # ссылаться, например, из оглавления книги (latex-формат)
        print "\\hypertarget{" + @section_yaml['id'] + "}{}"
        print "\n\n"
        # Вставляем заголовок главы книги
        print "# " + @section_yaml['title'] + "\n"
    end

    def print_rightalign(text)
        print "\\rightline{\\texttt{" + text + "}}\n"
    end

    def print_divbox_begin
        # Создаем отступы слева, справа, сверху и снизу для minipage, который описан ниже
        print "\\setlength{\\fboxsep}{0.05\\textwidth}"
        print "\n"
        # Создаем minipage под ширину страницы PDF-файла (с учетом отступов выше)
        print "\\fbox{\\begin{minipage}{0.9\\textwidth}"
    end

    def print_divbox_lastline_breaker
        print "}"
    end

    def print_divbox_end
        # Закрываем minipage
        print "\\end{minipage}}"
    end

    def print_divbox_line_breaker
        print "\\\\}" # \\\\ - попадет в latex как \\, что является для latex синонимом \n (перевод строки)
    end

    def preprocess_divbox!(line)
        # Удаляем символ \n в конце строки
        line.rstrip!
        # Преобразуем строки html-блока <div class="box">...</div> в latex-строки \texttt
        print "\\texttt{"
    end

    def get_underline_replacement
        "\\underline{\\1}"
    end

    def postprocess_divbox!(line)
        # Пробелы в начале строки заменяем на latex-отступ для смещения текста к правому краю minipage-а
        line.sub!(/^( )*/, "\\hspace*{\\fill}")
    end

    def get_hyperlink_replacement
        # Преобразование ссылок из md-формата в latex-формат
        # Примеры:
        # 1) преобразование ссылки на начало главы книги (например, из оглавления):
        #    [text](1-bla-bla-chapter-c01.html) -> \hyperlink{c01}{text}
        # 2) преобразование ссылки внутрь главы книги:
        #    [text](1-bla-bla-chapter-c01.html#p05) -> \hyperlink{c01p05}{text}
        "\\hyperlink{\\2\\3}{\\1}"
    end

    def get_anchor_replacement(id)
        # Преобразование разметки с якорем для ссылок из md-формата в latex-формат:
        # <a id="p05"></a> -> \hypertarget{c01p05}{}
        "\\hypertarget{" + id + "\\2}{}"
    end
end

PdfPreprocess.new.main