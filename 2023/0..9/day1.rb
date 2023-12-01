require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'day1.txt'))

REPLACES = [
  ['one', '1'],
  ['two', '2'],
  ['three', '3'],
  ['four', '4'],
  ['five', '5'],
  ['six', '6'],
  ['seven', '7'],
  ['eight', '8'],
  ['nine', '9']
].freeze


def is_digit?(c)
  code = c.ord
  # 48 is ASCII code of 0
  # 57 is ASCII code of 9
  code >= 48 && code <= 57
end

def replace_numbers_fwd(str)
  return str if str.empty?

  REPLACES.each do |replace_pair|
    return replace_numbers_fwd(replace_pair[1] + str.sub(replace_pair[0], '')) if str.start_with?(replace_pair[0])
  end

  str[0] + replace_numbers_fwd(str[1..])
end

def replace_numbers_bkd(str)
  return str if str.empty?

  REPLACES.each do |replace_pair|
    return replace_numbers_bkd(str[..-replace_pair[0].size-1]) + replace_pair[1] if str.end_with?(replace_pair[0])
  end

  replace_numbers_bkd(str[..-2]) + str[-1]
end


numbers = lines.map do |line|
  first_digit = line.chars.find { |c| is_digit?(c) }
  last_digit = line.chars.reverse.find { |c| is_digit?(c) }

  "#{first_digit}#{last_digit}".to_i
end

puts "part1: #{numbers.sum}"

numbers = lines.map do |line|
  first_digit = replace_numbers_fwd(line).chars.find { |c| is_digit?(c) }
  last_digit = replace_numbers_bkd(line).chars.reverse.find { |c| is_digit?(c) }

  puts "Line: #{line}#{first_digit}#{last_digit}\n\n"

  "#{first_digit}#{last_digit}".to_i
end

puts "part2: #{numbers.sum}"
