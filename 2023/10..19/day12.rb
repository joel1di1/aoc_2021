# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

DEBUG = true
records = File.readlines("#{__dir__}/input12.txt", chomp: true)

records_with_conditions = records.map do |record|
  left, right = record.split
  [left, right.split(',').map(&:to_i)]
end

def valid?(records, conditions)
  records.split('.').reject(&:empty?).map(&:size) == conditions
end

# puts records.inspect

assert valid?(".#.", [1])
assert valid?("..##..#..", [2, 1])
assert !valid?("..##..##..", [2, 1])

def possible?(record, conditions)
  return false if record.count('#') > conditions.sum
  return false if record.count('#') + record.count('?') < conditions.sum

  # debugger
  fixed_part = record[...(record.index('?') || record.size)]
  fixed_conditions = fixed_part.split('.').reject(&:empty?).map(&:size)

  if fixed_part.end_with?('#')
    fixed_conditions_to_test = fixed_conditions[...-1]
    fixed_part_to_test, last_group =  /([\.#]*\.)?(#+$)/.match(fixed_part)[1..2]
    return false if fixed_part_to_test && !valid?(fixed_part_to_test, conditions[...fixed_conditions_to_test.size])
    return false if last_group.size > (conditions[fixed_conditions.size - 1] || 0)
  else
    fixed_conditions_to_test = fixed_conditions
    fixed_part_to_test = fixed_part
    return false unless valid?(fixed_part_to_test, conditions[...fixed_conditions_to_test.size])
  end

  true
end

def count_possibilities(record, conditions)
  el = HeapElement.new(record, record.index('?') || record.size)

  heap = MaxHeap.new
  heap << el

  valids = 0

  until heap.empty?
    current = heap.pop.value

    puts "testing: #{current}, conditions: #{conditions}" if DEBUG

    if current.index('?').nil?
      if valid?(current, conditions)
        valids += 1
        puts "\tvalid: #{current}" if DEBUG
      else
        puts "\tinvalid: #{current}" if DEBUG
      end
      next
    end

    possible = possible?(current, conditions)
    puts "\tpossible: #{possible}" if DEBUG
    next if !possible?(current, conditions)

    nel = current.sub('?', '.')
    heap << HeapElement.new(nel, nel.index('?') || nel.size)
    nel = current.sub('?', '#')
    heap << HeapElement.new(nel, nel.index('?') || nel.size)
  end

  valids
end

assert_eq 1, count_possibilities('..#', [1])
assert_eq 0, count_possibilities('.##', [1])
assert_eq 2, count_possibilities('.??', [1])
assert_eq 2, count_possibilities('.?.?', [1])

# steps = 0
# part1 = records_with_conditions.map do |record, conditions|
#   steps += 1
#   puts "steps: #{steps} | record: #{record}, conditions: #{conditions}"
#   count_possibilities(record, conditions)
# end.sum

# puts "part1: #{part1}"

def count_possibilities_unfolded(record, conditions)
  unfolded = "#{record}?" * 5
  conditions *= 5

  puts "unfolded: #{unfolded}, conditions: #{conditions}"
  count_possibilities(unfolded, conditions)
end

# assert_eq 1, count_possibilities_unfolded('???.###', [1, 1, 3])

debugger
assert !possible?('..#......#......#..#######.#..#.########...###..#.##????#??????#..????????#??????#..??????', [9, 2, 1, 9, 2, 1, 9, 2, 1, 9, 2, 1, 9, 2, 1])

steps = 0
part2 = records_with_conditions.map do |record, conditions|
  steps += 1
  count_possibilities_unfolded(record, conditions)
end.sum

puts "part2: #{part2}"
