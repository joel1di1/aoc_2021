# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines("#{__dir__}/input13.txt", chomp: true)

# split the lines in patterns separated by empty lines
patterns = []
current = []
lines.each do |line|
  if line.empty?
    patterns << current
    current = []
  else
    current << line
  end
end

patterns << current

def summarize(line)
  # until the line is empty
  # take the first char
  # if # then 1 else 0
  sum = 0
  until line.empty?
    sum = (sum * 2) + (line[0] == '#' ? 1 : 0)
    line = line[1..]
  end
  sum
end

assert_eq 0, summarize('...')
assert_eq 1, summarize('..#')
assert_eq 3, summarize('.##')
assert_eq 4, summarize('#..')
assert_eq 8, summarize('#...')

def find_sym(summaries)
  sym_index = []
  (1...summaries.size).each do |i|
    size = [i, summaries.size - i].min
    # puts "i: #{i}, size: #{size}"
    sym_index << i if (0...size).all? do |j|
      # puts "check: #{summaries[i - j - 1]} == #{summaries[i + j]}"
      summaries[i - j - 1] == summaries[i + j]
    end
  end
  sym_index
end

def display_pattern(pattern)
  pattern.each do |line|
    puts line
  end
end

def find_horizontal_sym(pattern)
  # puts "\nfind_horizontal_sym"
  # display_pattern(pattern)

  summaries = pattern.map { |line| summarize(line) }

  # find the sym
  find_sym(summaries)
end

def find_vertical_sym(pattern)
  # puts "\nfind_vertical_sym"
  # display_pattern(pattern)
  cols = (0...pattern[0].size).map do |col|
    pattern.map { |line| line[col] }.join
  end
  summaries = cols.map { |line| summarize(line) }

  # find the sym
  find_sym(summaries)
end

def sum_pattern(pattern)
  horizontal_sym = find_horizontal_sym(pattern).first || 0
  vertical_sym = find_vertical_sym(pattern).first || 0

  (horizontal_sym * 100) + vertical_sym
end

part1 = patterns.map { |pattern| sum_pattern(pattern) }.sum

puts "Part1: #{part1}"


# Part 2
part2 = patterns.map do |pattern|
  origin_horizontal_sym = find_horizontal_sym(pattern).first
  origin_vertical_sym = find_vertical_sym(pattern).first

  pattern.map.with_index do |line, i|
    # line is a string, switch the char at index i
    # if it was a # then it becomes a . and vice versa
    (0...line.size).map do |j|
      line[j] = line[j] == '#' ? '.' : '#'

      # find the horizontal sym
        horizontal_syms = find_horizontal_sym(pattern)
        # debugger if horizontal_syms.size > 1
        horizontal_syms.delete(origin_horizontal_sym)
        horizontal_sym = horizontal_syms.first

      # find the vertical sym
        vertical_syms = find_vertical_sym(pattern)
        vertical_syms.delete(origin_vertical_sym)
        # debugger if vertical_syms.size > 0
        vertical_sym = vertical_syms.first

      line[j] = line[j] == '#' ? '.' : '#'

      res = ((horizontal_sym || 0) * 100) + (vertical_sym || 0)
      # puts "i: #{i}, j: #{j}, res: #{res}"
      res
    end.uniq
  end
end.flatten.sum


puts "Part2: #{part2/2}"
