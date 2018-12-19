#!/usr/bin/env ruby

require 'open3'

# Команда по вставке перед md-файлом главы разрыва страницы и заголовка этой главы
md_to_md_command = "cat %{mdfile} | pandoc --template=_latex/section.latex -t markdown"

max_book_footnote_number = 0 # общее число ссылок в книге
ARGV.each do |chapter_md_file| # перебираем md-файлы глав книги
    max_chapter_footnote_number = 0 # общее число ссылок в главе
    Open3.popen3(md_to_md_command % {mdfile: chapter_md_file}) do |cmdin, cmdout, cmderr, cmdstatus, cmdthread|
        while line = cmdout.gets do # построчно читаем md-файл главы книги
            # FIXME обработать ситуацию, когда в одной строке несколько сносок
            chapter_footnote_number_match = line.match(/\[\^(\d+)\]/) # ищем сноску в строке главы
            unless chapter_footnote_number_match.nil? # если сноска найдена, то
                # Получаем номер сноски (Pandoc нумирует сноски натуральными числами (от 1 и выше))
                chapter_footnote_number, = chapter_footnote_number_match.captures
                chapter_footnote_number = chapter_footnote_number.to_i
                # Меняем номер сноски в главе, который поставил Pandoc, на сквозной для всей книги номер сноски
                line = line.gsub(/\[\^\d+\]/, "[^" + (chapter_footnote_number + max_book_footnote_number).to_s + "]")
                # Считаем общее число ссылок в главе
                if chapter_footnote_number > max_chapter_footnote_number
                    max_chapter_footnote_number = chapter_footnote_number
                end
            end
            # Вывод строки из главы книги в стандартный поток вывода
            print line
        end
    end
    # Считаем общее число ссылок в книге
    max_book_footnote_number += max_chapter_footnote_number
end


