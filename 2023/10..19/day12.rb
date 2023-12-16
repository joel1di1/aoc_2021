# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

records = File.readlines("#{__dir__}/input12.txt", chomp: true)

records_with_conditions = records.map do |record|
  left, right = record.split
  [left, right.split(',').map(&:to_i).freeze].freeze
end

CACHE = {}

def arrangements(record, conditions)
  puts "arr, record: #{record}, conds: #{conditions}"
  # debugger if record == '#?.?.?'
  cache_key = [record, conditions]
  return CACHE[cache_key] if CACHE.key?(cache_key)

  if record.nil? || record.empty?
    return 1 if conditions.empty?
    return 1 if conditions == [0]

    return 0
  end

  cons = conditions.dup
  result = case record[0]
           when '#'
             con = cons[0]
             if con.nil? || record.size < con || con < 0
               0
             elsif record[...con].match(/(#|\?){#{con}}/)
               if record[con] == '#'
                 0
               else
                # debugger if record == '#??.###???.###???.###???.###???.###'
                 arrangements(".#{record[con+1..]}", cons[1..])
               end
             else
               0
             end
           when '?'
             if conditions.first.nil?
               arrangements(".#{record[1..]}", conditions)
             elsif conditions.first < 0
               0
             elsif conditions.first == 0
               cons.shift
               arrangements(".#{record[1..]}", cons)
             else
               puts "\task for #{".#{record[1..]}"}, #{conditions}"
               puts "\t\t#{"##{record[1..]}"}, #{conditions}"
               arrangements(".#{record[1..]}", conditions) + arrangements("##{record[1..]}", conditions)
             end
           when '.'
             if conditions.first == 0
               cons.shift
               arrangements(record[1..], cons)
             else
               arrangements(record[1..], conditions)
             end
           else
             raise "Unexpected #{record[0]}"
           end

  CACHE[cache_key] = result

  puts "#{record} #{conditions} => #{result}"

  result
end

# assert_eq 1, arrangements('#', [1])
# assert_eq 1, arrangements('?', [1])
# assert_eq 0, arrangements('.', [1])

# assert_eq 1, arrangements('', [])
# assert_eq 0, arrangements('', [1])
# assert_eq 0, arrangements('', [1, 2])

# assert_eq 1, arrangements('##', [2])
# assert_eq 1, arrangements('###', [3])
# assert_eq 0, arrangements('##', [1])
# assert_eq 0, arrangements('##', [3])

# assert_eq 1, arrangements('.#', [1])
# assert_eq 1, arrangements('#.#', [1, 1])

# assert_eq 1, arrangements('?.?', [1, 1])
# assert_eq 2, arrangements('??.?.?', [1, 1, 1])

# assert_eq 2, arrangements('??', [1])

# assert_eq 4, arrangements('.??..??...?##.', [1, 1, 3])


# assert_eq 2, arrangements('#????', [2, 1])

# assert_eq 10, arrangements('???????', [2, 1])


# assert_eq 10, arrangements('?###????????', [3, 2, 1])

# puts 'OK'

# result = records_with_conditions.map do |record, conditions|
#   # puts "#{record} #{conditions} => #{arrangements(record, conditions)}"
#   arrangements(record, conditions)
# end.sum

# puts "part 1: #{result}"


def unfolded_arrangements(record, conditions)

  arrangements(Array.new(5) { record }.join('?'), conditions*5)
end

assert_eq 1, unfolded_arrangements('???.###', [1, 1, 3])

result = records_with_conditions.map do |record, conditions|
  unfolded_arrangements(record, conditions)
end.sum

puts "part2: #{result}"
