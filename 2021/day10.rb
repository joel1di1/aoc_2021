# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

OPENERS = '([{<'.chars
CLOSERS = '})]>'.chars

MATCH = { '}' => '{', ']' => '[', ')' => '(', '>' => '<' }.freeze
REVERSE = { '{' => '}', '[' => ']', '(' => ')', '<' => '>' }.freeze
SCORE = { '}' => 1197, ']' => 57, ')' => 3, '>' => 25137 }.freeze
INCOMPLETE_SCORE = {
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4
}.freeze

def score(file)
  incompletes = File.readlines(file).map(&:chars).map do |chars|
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
    score = 0
    if illegal.nil?
      while !pile.empty?
        score = 5 * score
        closer = REVERSE[pile.pop]
        score += INCOMPLETE_SCORE[closer]
      end
      score
    else
      nil
    end
  end

  incompletes.compact!
  incomplete_score = incompletes.sort[incompletes.size / 2]
  puts "Incomplete score of #{file}: #{incomplete_score}"

  incomplete_score
end

s = score('day10_sample.txt')
raise "nope #{s}" if s != 288957

score('day10.txt')[]
