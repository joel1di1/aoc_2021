# frozen_string_literal: true

require 'byebug'
require 'readline'

def process(file)
  numbers = File.readlines(file).map(&:to_i).sort
  numbers << numbers.max + 3
  numbers.insert(0,0 )

  tally = (0..numbers.size - 2).map { |index| numbers[index+1] - numbers[index]}.tally

  tally[1] * tally[3]
end

sample_result = process('day10_sample.txt')
expected = 220

puts "Sample Result: #{sample_result}"
raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected

puts "Result: #{process('day10.txt')}"