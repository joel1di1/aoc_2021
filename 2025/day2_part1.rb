require_relative '../fwk'

lines = File.readlines(File.join(__dir__, 'input2.txt'))

line = lines[0]

ranges = line.split(',')

ranges = ranges.map do |r| 
  s, e = r.split('-')
  (s.to_i..e.to_i)
end

def invalid?(number)
  number_s = number.to_s
  return false if number_s.size.odd?

  left, right = number_s.chars.each_slice(number_s.length / 2).map(&:join)
  left == right
end

def assert_invalid(number)
  raise "#{number} should be invalid" unless invalid?(number)
end

def assert_valid(number)
  raise "#{number} should be invalid" if invalid?(number)
end


assert_invalid(11)
assert_invalid(1212)
assert_invalid(123123)
assert_valid(1)
assert_valid(12)
assert_valid(123)
assert_valid(1231234)

sum = 0
ranges.each do |range|
  range.each do |num|
    sum += num if invalid?(num)
  end
end

puts "part 1: #{sum}"