# jekyll-book
A Jekyll and Bootstrap framework for publishing a book online in multiple formats.

This project was forked from [travist/jekyll-kickstart](https://github.com/travist/jekyll-kickstart), a nice framework for starting a clean [Jekyll](https://jekyllrb.com/) 
site with minimal [Bootstrap](http://getbootstrap.com/). Jekyll-Book extends it with a set of plugins, include files and conventions to support a book-like publication. A set of 
[Markdown](https://daringfireball.net/projects/markdown/) files are rendered into a sequence of interlinked pages, and also into a single PDF (and other output files) for downloading. 

An example project: [Github repo](https://github.com/pbinkley/jekyll-book-marriage); [public site](https://www.wallandbinkley.com/rcb/works/marriage/)

## Установка программы jekyll-book

Ниже описан процесс установки на Windows, но я старался все сделать так,
чтобы в Linux тоже работало. Однако все ссылки на скачивание доп. программ
будут даны именно под систему Windows. Работоспособность проверялась на Windows 10.
Кроме того, все доп. программы качались в 32-битном издании, несмотря на 64-битную
систему (это магия Windows 10... Не смейтесь и не спрашивайте;)...).

Итак приступим:
- Необходимо скачать и установить `Ruby` (требуется 2.0+). 
Я у себя ставил [Ruby Installer Devkit 2.5.3-1](https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/rubyinstaller-devkit-2.5.3-1-x86.exe)<br/>
В процессе установки ставьте и `MSYS2` тоже (нужно отметить галочкой), а по завершении установки,
прежде чем нажать кнопку `Finish`, нужно отметить еще галочку: `Run 'ridk install' ...`,
чтобы установить `Ruby` по максимум. Если этого не сделать, то при запуске `jekyll` все равно
запросят выполнить команду `ridk install`, поэтому это обязательное условие
- Устанавливаем `Ruby Bundler` в консоли (`gem install bundler`)
- Устанавливаем [Python 2.7.15](https://www.python.org/ftp/python/2.7.15/python-2.7.15.msi) (требуется 2.x)<br/>
Потребуется для устанвки программы через `bundle install`, т.к. некоторые `gem`-ы собираются
при помощи `Python`-а (вопрос почему они не собираются через `Ruby` для меня открыт, но факт остается фактом)
- Устанавливаем [Pandoc 2.5](https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-windows-i386.msi)<br/>
Потребуется для генерации книги в различных форматах из md-формата,
а также для генерации сайта `jekyll`-ом из того же md-формата
(для этого чаще всего используется `kramdown` (т.к. он целиком написан на `Ruby`),
но я буду использовать `Pandoc`, т.к. он поддерживает более богатый набор выходных форматов)
- Устанавливаем [MikTex 2.9](https://mirror.datacenter.by/pub/mirrors/CTAN/systems/win32/miktex/setup/windows-x86/basic-miktex-2.9.6850.exe)<br/>
Потребуется `Pandoc`-у для генерации PDF документов через latex-шаблон
- Для полноценной работы нашей программы с `MikTex` нужно установить для него ряд шрифтов и плагинов:
  - установить в ОС шрифт, который является клоном `Times` и умеет работать с математическими спец. символами
  [texgyretermes-math.otf](https://github.com/fortran-team/ethertheories.com/tree/master/_latex/_misc/_fonts)
  - положить все необходимые [`MikTex` плагины](https://github.com/fortran-team/ethertheories.com/tree/master/_latex/_misc/_TEXMF) в его папку `%TEXMF%`.
  Чтобы найти эту папку нужно запустить программу `MikTex Console`, там выбрать раздел `Settings`,
  далее перейти на вкладку `Directories` и изучить табличку с папками `MikTex`. Нам нужна строка
  таблицы, где в поле `Purposes` написано слово `Config`. Для этой строки смотрим поле `Path` таблицы.
  Там будет написан путь к папке, которая условно называется `%TEXMF%`. В моем случае этот путь был
  следующим: `C:\Users\%имя_пользователя%\AppData\Roaming\MiKTeX\2.9`
  - после того, как все нужные файлы попали в папку `%TEXMF%` нужно дать команду
  `MikTex` обновить свою БД и обнаружить эти плагины. Это делается через ту же программу `MikTex Console`,
  где нужно зайти в меню `Tasks` и там нажать `Refresh file name database`
  - последнее, что хочется добавить - это компилирование sty-файлов плагинов `MikTex` из исходников в 
  файлах *.ins и *.dtx. Это процесс подробно описан в моем [Gist](https://gist.github.com/professor-fortran/d41b02eac31573f8628d615d31b92148).<br/>
  Однако все необходимые [`MikTex` плагины](https://github.com/fortran-team/ethertheories.com/tree/master/_latex/_misc/_TEXMF) уже скомпилированы,
  поэтому вам этого делать не нужно. Здесь это написано лишь на случай, если вы будете дорабатывать программу и понадобятся другие
  плагины, которые у меня не использовались
- Клонируйте этот репозиторий
- Нужно поставить плагин `jekyll-lunr-js-search`, но не нужно делать это командой:<br/>
  `gem install jekyll-lunr-js-search`,<br/>
  т.к. в этом случае `Ruby` поставит себе плагин версии `3.3.0`, который лежит в [gem-репозитории](https://rubygems.org/gems/jekyll-lunr-js-search)
  и который использует библиотеку `therubyracer` для исполнения в `Ruby` `JavaScript`-скриптов.
  Нам это не подходит, т.к. библиотека `therubyracer` работает только в Linux.
  Однако автор данного плагина уже обновил свой код на GitHub, где заменил `therubyracer` на
  универсальную библиотеку `execjs`, но не выложил данную версию плагина в gem-репозиторий. Поэтому я склонировал GitHub-код
  автора плагина и сделал сборку самого актуального gem-файла данного плагина.
  Скачать его можно в моем [GitHub](https://github.com/fortran-team/jekyll-lunr-js-search-with-gem/blob/master/jekyll-lunr-js-search-3.3.0.execjs.vice.therubyracer.gem)
  и после этого вручную установить себе в систему:<br/>
  `gem install jekyll-lunr-js-search-3.3.0.execjs.vice.therubyracer.gem`
- В директории репозитория запустите команду<br/>
    `bundle install`,<br/>
  чтобы поставить все нужные для работы `gem`-ы
- Устанавливаем [NodeJS](https://nodejs.org/dist/v10.14.2/node-v10.14.2-x86.msi).
  Тут надо дать небольшое пояснение. Упомянутая выше библиотека `execjs` может работать на любой платформе. В том
  числе она может работать и на Windows, используя ее JavaScript-машину JScript. Однако из-за бага в JScript на
  данный момент работа `execjs` в этом режиме невозможна. Но можно установить `NodeJS` и когда `execjs` увидит его
  в системе, то будет автоматически работать через него 
- Запустите программу командой<br/>
    `jekyll serve`
- Сайт запустится на вашей локальной машине по адресу<br/>
    [http://127.0.0.1:4000/ethertheories.com/](http://127.0.0.1:4000/ethertheories.com/)

## Customization

### Metadata

The bibliographic metadata for the book is entered in ```_config.yml```:

```
title: Title of Book
brand: Title of Book
subtitle: Book has a subtitle
author: Mary Author
date: 1918
description: >
  Author, Title (Place: Publisher, Year)
# description_latex is included in the PDF, so it uses LaTeX formatting
description_latex: >
  Author, \textit{Title} (Place: Publisher, Year)
editor: Jim Editor
twitter: "@mytwitterhandle" # included 
license_icon: publicdomain # specified image in assets directory
license_text: "To the extent possible under law, Jim Editor has waived all copyright and related or neighboring rights to \"Title of Book\". This work is published from: Canada."
# link back to this site in PDF; or just delete this line
jb_credit_latex: "Generated with jekyll-book ¶ \\href{https://github.com/pbinkley/jekyll-book}{https://github.com/pbinkley/jekyll-book}"
# Info for CC license vcard in _includes/license.html
publisher_url: "http://www.domain.com/publisher/"
country_name: Canada
country_code : CA
```

The full citation should also be added to ```_includes/citation.html```.

### Content

Content files belong in the ```sections``` directory. They will be rendered according to the alphabetical order of file names, so they should be named accordingly.

Each file should have a YAML metadata header:

```
---
layout: section               # invokes _layouts/section.html
title: "Chapter 2: Tables"    # used in HTML head, jumbotron div, etc.
permalink: 02-chapter2.html   # name of rendered file
id: s02                       # used as id of article element, for chapter-
                              #    specific CSS
group: sections               # grouping in dropdown menus
---
```

#### HTML filtering

The approach jekyll-books takes is to try to make the Markdown-to-HTML transformation work without intervention, and then to tweak the other transformations as needed. There are a few things, though, that get tweaked on the way to the HTML site. For example: to look good in the PDF, the Markdown files should begin with a second-level header title:

```
## Chapter 2: Tables
```

This will appear in all of the downloadable versions. In the HTML, though, we want to suppress it, since the chapter title appears in the ```jumbotron``` div above the ```article``` div (and is drawn from the ```title``` property in the page's YAML block). Removing it is done in the ```_layouts/section.html``` template:


```
  <article id="{{ page.id}}" class="post-content">
    {{ content 	    	
    	| replace_regex: '<h2.*</h2>', '', true 
	}}
  </article>
```

The content of the article (which has already been rendered into HTML) is passed to the replace_regex method (defined in ```_plugins/replace.rb```), which replaces the first occurence of an ```h2``` heading with an empty string. More replacement operations could be chained together as needed.

### Downloadable Formats

In addition to generating an HTML site in the normal Jekyll way, jekyll-book generates a set of downloadable files such as a PDF, containing the full text of the book. These downloads are generated by ```pandoc```; the full set of formats and the commands used to generate them are defined in the ```downloads``` section of ```_config.yml```:

```
downloads:
    pdf:
      deps: ["_config.yml","_latex/jekyll-book.latex","_scripts/preprocess.rb"]
      command: "cat _config.yml sections/*.md | _scripts/preprocess.rb | pandoc --latex-engine=xelatex --template=_latex/jekyll-book.latex -f markdown+pipe_tables+footnotes -o %{dirDownloads}/%{slug}.pdf"
    epub:
      deps: ["_config.yml","_epub-metadata.yml","assets/cover.jpg"]
      command: "pandoc -S --epub-cover-image=assets/cover.jpg --epub-metadata=_epub-metadata.yml -f markdown+pipe_tables+footnotes sections/*.md  -o %{dirDownloads}/%{slug}.epub"
    md:
      deps: ["_config.yml"]
      command: "pandoc sections/*.md -t plain -o %{dirDownloads}/%{slug}.txt"
    txt:
      deps: ["_config.yml"]
      command: "pandoc sections/*.md -o %{dirDownloads}/%{slug}.md"
```

(These commands work in a \*nix environment; they may need tweaking to run under Windows.) The generating of download files is handled by ```_plugins/renderdownloads.rb```, which determines which downloads need to be regenerated and runs the appropriate commands. The basename for these files (```%{slug}```) is computed by slugifying the ```brand``` property specified in ```_config.yml```. 

New downloads are generated if the content or any of the dependencies (specified in the ```deps``` property) have been added, deleted or modified. The state of these files is tracked the same way ```git``` does, with SHA1 hashes stored in ```_data/previousrun.yml``` (the timestamp is not used). Preventing redundant regeneration allows users to avoid downloading newly-generated download files that are identical to the previous version. This is particularly important for the PDF, which includes a timestamp on the title page and therefore would appear to be a substantially new version when in fact nothing has changed but the timestamp.

#### PDF

Pandoc uses LaTeX to generate PDFs, and jekyll-book uses a slightly customized LaTeX template: ```_latex/jekyll-book.latex```. Most of the customization is there to generate an informative title page using metadata properties drawn from ```_config.yml```. To enable this, ```_config.yml``` is passed as the YAML metadata block for the concatenated sequence of Markdown files. 

The concatenated Markdown is fed through ```_scripts/preprocess.rb```. This script strips out the files' own YAML blocks, since we only want the ```_config.yml``` block to be present. It can be extended to make other changes, especially by substituting or adding LaTeX strings to achieve particular formatting effects. For example, a project that required certain paragraphs to be right-justified specified them in HTML in the raw Markdown:

```
<p class="right">LC</p>
```

This was handled by ```preprocess.rb``` like this:

```
if /<p class=\"right\".*/.match(line)
	print "\\rightline{" + /\>(.*)\</.match(line)[1] + "}\n"
```

Giving the output:

```
\rightline{LC}
```

Obviously, these hacks go beyond ["the simple, clear, ASCII email inspired spirit of Markdown"](https://blog.codinghorror.com/standard-flavored-markdown/) and should be kept to a minimum.

#### EPUB

The EPUB generator hasn't had much attention yet but should be enhanced in the same way that the PDF one has, to make better use of the metadata and provide a better-looking template.

### Dependencies

The following javascript and CSS libraries are included:

* [jQuery](https://jquery.com/)
* [jQuery Easing](https://github.com/gdsmith/jquery.easing)
* [jQuery Fragment Scroll](https://github.com/miWebb/jQuery.fragmentScroll) ([forked](https://github.com/pbinkley/jQuery.fragmentScroll) and modified to handle incoming url fragments)
* [Bootstrap](http://getbootstrap.com/)

Other dependencies are listed in the Gemfile.