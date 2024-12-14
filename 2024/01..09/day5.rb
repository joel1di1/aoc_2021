require 'byebug'

lines = File.readlines(File.join(__dir__, 'input5.txt')).map(&:strip)

rules = {}
updates = []

lines.each do |line|
  case line
  when /(\d+)\|(\d+)/
    first = $1.to_i
    second = $2.to_i
    rules[first] ||= []
    rules[first] << second
  when /(\d+),/
    updates << line.split(',').map(&:to_i)
  end
end

part1 = updates.reject do |update|
  (0..update.size-1).any? do |i|
    current_value = update[i]
    must_be_after = rules[current_value] || []

    puts "update: #{update}, i: #{i}, current_value: #{current_value}, must_be_after: #{must_be_after}"
    puts "res: #{update[0...i] & must_be_after}\n"

    res = (update[0...i] & must_be_after)
    res.size > 0
  end
end.map do |update|
  # value in the middle of ythe array
  update[update.size/2]
end

puts "part1: #{part1.sum}"
