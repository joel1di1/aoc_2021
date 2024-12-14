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

    res = (update[0...i] & must_be_after)
    res.size > 0
  end
end.map do |update|
  # value in the middle of ythe array
  update[update.size/2]
end

puts "part1: #{part1.sum}"

incorrectly_ordered = updates.select do |update|
  (0..update.size-1).any? do |i|
    current_value = update[i]
    must_be_after = rules[current_value] || []

    res = (update[0...i] & must_be_after)
    res.size > 0
  end
end

sum = incorrectly_ordered.map do |update|
  mid_value = nil;
  update.each_with_index do |value, i|
    if mid_value.nil?
      must_be_after = rules[value] || []

      res = update & must_be_after
      if res.size == (update.size/2)
        mid_value = value
      end
    end
  end
  mid_value
end.sum

puts "part2: #{sum}"
