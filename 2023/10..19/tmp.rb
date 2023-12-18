# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

def write_uniq_words(filename_src, filename_dst)
  words = File.readlines(filename_src, chomp: true).map(&:split).flatten.uniq
  File.open(filename_dst, 'w') do |file|
    words.each do |word|
      file.puts(word)
    end
  end
end


def write_words_in_reversed_order(filename_src, filename_dst)
  words = File.readlines(filename_src, chomp: true).map(&:split).flatten
  File.open(filename_dst, 'w') do |file|
    words.reverse_each do |word|
      file.puts(word)
    end
  end
end

write_words_in_reversed_order("/Users/bla/joe/projects/textdys/python/uniq_words.txt", "/Users/bla/joe/projects/textdys/python/reverse_words.txt")
