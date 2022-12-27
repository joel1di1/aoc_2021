# Read the input file and parse it into an array of strings
lines = File.read("day3.txt").split("\n")

# Define a mapping from characters to priorities
PRIORITIES = ('a'..'z').each_with_index.to_h { |c, i| [c, i+1] }.merge(('A'..'Z').each_with_index.to_h { |c, i| [c, i+27] })

# Initialize a variable to store the sum of the priorities
sum = 0

# Iterate over the array of strings in groups of 3
lines.each_slice(3) do |group|
  # Find the common item type by intersecting the sets of characters in each string
  common_item_type = group[0].chars & group[1].chars & group[2].chars

  # Find the priority of the common item type
  priority = PRIORITIES[common_item_type.first]

  # Add the priority to the sum
  sum += priority
end

# Print the result
puts sum
