#!/usr/bin/env ruby

require 'open3'

# Команда по вставке перед md-файлом главы разрыва страницы и заголовка этой главы
md_to_md_command = "cat %{mdfile} | pandoc --template=_latex/section.latex -t markdown"

# Регулярка на поиск сносок
footnote_regexp = /\[\^(\d+)\]/

max_book_footnote_number = 0 # общее число сносок в книге
ARGV.each do |chapter_md_file| # перебираем md-файлы глав книги
    max_chapter_footnote_number = 0 # общее число сносок в главе
    Open3.popen3(md_to_md_command % {mdfile: chapter_md_file}) do |cmdin, cmdout, cmderr, cmdstatus, cmdthread|
        while line = cmdout.gets do # построчно читаем md-файл главы книги
            chapter_footnote_number_scanarray = line.scan(footnote_regexp) # ищем все сноски в строке главы
            unless chapter_footnote_number_scanarray.empty? # если сноски в строке есть, то
                # Делаем массив одномерным, т.к. chapter_footnote_number_scanarray зачем-то сделан двумерным
                chapter_footnote_number_array = chapter_footnote_number_scanarray.flatten
                replacement_map = {} # map-а замен старых номеров сносок на новые номера сносок
                chapter_footnote_number_array.each do |chapter_footnote_number_str| # перебираем все сноски в строке
                    # Получаем номер сноски (Pandoc нумирует сноски натуральными числами (от 1 и выше))
                    chapter_footnote_number = chapter_footnote_number_str.to_i
                    # Составляем map-у замен сносок с номерами, которые поставил Pandoc, на сноски со сквозной для всей книги нумерацией
                    replacement_map["[^" + chapter_footnote_number_str + "]"] = "[^" + (chapter_footnote_number + max_book_footnote_number).to_s + "]"
                    # Считаем общее число сносок в главе
                    if chapter_footnote_number > max_chapter_footnote_number
                        max_chapter_footnote_number = chapter_footnote_number
                    end
                end
                # Производим замену сносок по map-е, которую составили выше
                line = line.gsub(footnote_regexp, replacement_map)
            end
            # Вывод строки из главы книги в стандартный поток вывода
            print line
        end
    end
    # Считаем общее число сносок в книге
    max_book_footnote_number += max_chapter_footnote_number
end


