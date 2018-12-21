#!/usr/bin/env ruby

require_relative 'abstract_preprocess_epub,md'

class EpubPreprocess < AbstractEpubMdPreprocess
end

EpubPreprocess.new.main