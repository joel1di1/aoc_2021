# Import the Set class
require 'set'
require 'byebug'

# Read the input from the file
lines = File.read("day3.txt").strip.split("\n")
compartments = lines.map { |line| [line[0...(line.length/2)], line[(line.length/2)..-1]] }

# Group the compartments into sets of three
groups = compartments.each_slice(3).to_a

# Find the common letter in each group
common_letters = groups.map do |group|
  # Flatten the group into a single array of characters, then convert it to a set
  debugger
  chars = group.flatten.chars.to_set
  # Find the intersection of all characters in the set
  chars.inject { |intersection, chars| intersection & chars }
end

# Convert each common letter to its priority, then sum the priorities
priorities = common_letters.map do |c|
  if c.ord >= 'a'.ord && c.ord <= 'z'.ord
    c.ord - 'a'.ord + 1
  elsif c.ord >= 'A'.ord && c.ord <= 'Z'.ord
    c.ord - 'A'.ord + 27
  else
    raise "Invalid character: #{c}"
  end
end.sum

puts priorities
