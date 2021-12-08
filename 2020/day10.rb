# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

def build_numbers(file)
  numbers = File.readlines(file).map(&:to_i).sort
  numbers << numbers.max + 3
  numbers.insert(0, 0)
  numbers
end

def process(file)
  numbers = build_numbers(file)

  tally = (0..numbers.size - 2).map { |index| numbers[index + 1] - numbers[index] }.tally

  tally[1] * tally[3]
end

sample_result = process('day10_sample.txt')
expected = 220

puts "Sample Result: #{sample_result}"
raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected

puts "Result: #{process('day10.txt')}"

def valid?(numbers)
  (0..numbers.size - 2).map do |index|
    return false if numbers[index + 1] - numbers[index] > 3
  end
  true
end

@iter = 0

def count_ways(numbers, sols = Set.new)
  @iter += 1
  puts "iter: #{@iter}, sols: #{sols.size}, numbers: #{numbers} " if @iter % 100000 == 0

  sols << numbers
  (1..numbers.size - 2).map do |index|
    if numbers[index + 1] - numbers[index - 1] <= 3
      sub = numbers - [numbers[index]]
      sols.include?(sub) ? nil : sub
    end
  end.compact.map { |numbers| count_ways(numbers, sols) }.sum + 1
end

def part2(file)
  count_ways(build_numbers(file))
end

sample_result = part2('day10_sample.txt')
expected = 19208

puts "\n\n\nSample Result: #{sample_result}"
raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected

puts "Result: #{part2('day10.txt')}"
