# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

OPENERS = '([{<'.chars
CLOSERS = '})]>'.chars

MATCH = { '}' => '{', ']' => '[', ')' => '(', '>' => '<' }.freeze
SCORE = { '}' => 1197, ']' => 57, ')' => 3, '>' => 25137 }.freeze

def score(file)
  illegals = File.readlines(file).map(&:chars).map do |chars|
    pile = []
    illegal = nil
    chars.each do |c|
      case c
      when /[\[\(\{<]/
        pile << c
      when /[\]\)\}>]/
        if MATCH[c] != pile.pop
          illegal = c
          break
        end
      when /\s/
      else
        raise "unknown: #{c}"
      end
    end
    illegal
  end

  score = illegals.compact.map { |c| SCORE[c] }.sum
  puts "Score of #{file}: #{score}"
  score
end

s = score('day10_sample.txt')
raise "nope #{s}" if s != 26397
s = score('day10.txt')
