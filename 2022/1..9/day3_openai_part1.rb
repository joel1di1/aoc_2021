# frozen_string_literal: true

# Read the contents of the input file into a list of strings
lines = File.readlines('day3.txt')

# Initialize a variable to store the sum of the priorities
sum = 0

# Iterate through the list of strings
lines.each do |line|
  # Split the string into two compartments
  compartment1 = line[0, line.length / 2]
  compartment2 = line[line.length / 2, line.length / 2]

  # Create a frequency map for each compartment
  freq1 = compartment1.chars.each_with_object(Hash.new(0)) { |char, counts| counts[char] += 1 }
  freq2 = compartment2.chars.each_with_object(Hash.new(0)) { |char, counts| counts[char] += 1 }

  # Find the character that appears in both compartments
  char = freq1.keys & freq2.keys

  # Calculate the priority of the character and add it to the sum
  sum += char.map { |c| c.match(/[a-z]/) ? c.ord - 'a'.ord + 1 : c.ord - 'A'.ord + 27 }.sum
end

# Print the sum of the priorities
puts sum
