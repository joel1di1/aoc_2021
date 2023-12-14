# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

DEBUG = false
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

CACHE_POSSIBLE = {}

def possible?(record, conditions)
  if CACHE_POSSIBLE[[record, conditions]]
    return CACHE_POSSIBLE[[record, conditions]]
  end

  res = _possible?(record, conditions)
  CACHE_POSSIBLE[[record, conditions]] = res
  res
end

def _possible?(record, conditions)
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

CACHE = {}

def count_possibilities_cached(record, conditions)
  # puts "ask cached: #{record}, conditions: #{conditions}" if DEBUG
  if CACHE[[record, conditions]]
    puts "process record: #{record}, conditions: #{conditions}: cache hit: #{CACHE[[record, conditions]]}" if DEBUG
    return CACHE[[record, conditions]]
  end

  res = count_possibilities_rec(record, conditions)
  puts "process record: #{record}, conditions: #{conditions}: cache miss: #{res}" if DEBUG
  CACHE[[record, conditions]] = res
  res
end

def count_possibilities_rec(record, conditions)
  # puts "ask rec: #{record}, conditions: #{conditions}" if DEBUG
  debugger if record == '#???###??????????###??????????###??????????###?????????'

  if record.nil?
    return conditions.empty? ? 1 : 0
  end

  case record[0]
  when nil
    return conditions.empty? ? 1 : 0
  when '.'
    return count_possibilities_cached(record[1..], conditions)
  when '#'
    number_of_dash = conditions.first
    return 0 if number_of_dash.nil?
    return 0 if record.size < number_of_dash
    return 0 if record[0...number_of_dash].count('.') > 0
    return 0 if record[number_of_dash] == '#'

    next_record = record[number_of_dash+1..]
    return count_possibilities_cached(next_record, conditions[1..])
  when '?'
    return count_possibilities_cached(record.sub('?', '#'), conditions) + count_possibilities_cached(record.sub('?', '.'), conditions)
  end

end

assert_eq 1, count_possibilities_cached('?', [1])
assert_eq 1, count_possibilities_cached('..#', [1])
assert_eq 0, count_possibilities_cached('.##', [1])
assert_eq 2, count_possibilities_cached('.??', [1])
assert_eq 2, count_possibilities_cached('.?.?', [1])

steps = 0
part1 = records_with_conditions.map do |record, conditions|
  steps += 1
  puts "steps: #{steps} | record: #{record}, conditions: #{conditions}"
  count_possibilities(record, conditions)
end.sum

puts "part1: #{part1}"

def count_possibilities_unfolded(record, conditions)
  unfolded = "#{record}?" * 5
  conditions *= 5

  count_possibilities(unfolded, conditions)
end

# # assert_eq 1, count_possibilities_cached('???.###', [1, 1, 3])
assert_eq 16384, count_possibilities_unfolded('.??..??...?##.', [1, 1, 3])
assert_eq 16, count_possibilities_unfolded('????.#...#...', [4,1,1])
assert_eq 2500, count_possibilities_unfolded('????.######..#####.', [1,6,5])

# assert_eq 1, count_possibilities_cached('#??.###', [1,1,3])

# assert_eq 506250, count_possibilities_unfolded('?###????????', [3,2,1])

# # 759375

steps = 0
part2 = records_with_conditions.map do |record, conditions|
  steps += 1
  puts "steps: #{steps} | record: #{record}, conditions: #{conditions}"
  count_possibilities_unfolded(record, conditions)
end.sum

puts "part2: #{part2}"
