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

def find_horizontal_sym(pattern)
  puts "\nfind_horizontal_sym"
  display_pattern(pattern)

  summaries = pattern.map { |line| summarize(line) }

  # find the sym
  find_sym(summaries)
end

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
  # puts "sym_index: #{sym_index}"
  raise 'too many syms' if sym_index.size > 1

  sym_index.first
end

def display_pattern(pattern)
  pattern.each do |line|
    puts line
  end
end

def find_vertical_sym(pattern)
  puts "\nfind_vertical_sym"
  display_pattern(pattern)
  cols = (0...pattern[0].size).map do |col|
    pattern.map { |line| line[col] }.join
  end
  summaries = cols.map { |line| summarize(line) }

  # find the sym
  find_sym(summaries)
end


sums = patterns.map do |pattern|
  puts "check pattern:"
  pattern.each do |line|
    puts line
  end
  puts

  horizontal_sym = find_horizontal_sym(pattern) || 0
  vertical_sym = find_vertical_sym(pattern) || 0

  puts "horizontal_sym: #{horizontal_sym}, vertical_sym: #{vertical_sym}"

  (horizontal_sym * 100) + vertical_sym
end.sum

puts "sums: #{sums}"
