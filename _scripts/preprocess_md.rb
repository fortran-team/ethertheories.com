#!/usr/bin/env ruby

require_relative 'abstract_preprocess_epub,md'

class MdPreprocess < AbstractEpubMdPreprocess
    def print_cover_and_title_pages(main_yaml)
        print "![](" + main_yaml['url'] + "/" + main_yaml['cover_image'] + ")"
        print "\n\n"
        print "# " + main_yaml['title']
        print "\n\n"
        print "### " + main_yaml['subtitle']
        print "\n\n"
        print "by"
        print "\n\n"
        print "### " + main_yaml['author']
        print "\n\n"
        print "#### " + main_yaml['publisher']
        print "\n\n"
        print "#### " + main_yaml['date'].to_s
        print "\n\n"
    end
end

MdPreprocess.new.main