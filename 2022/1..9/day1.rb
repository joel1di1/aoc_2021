# Read input from day1.txt
input = File.read("day1.txt")

# Split input into individual lines
lines = input.split("\n")

# Create a hash to store each Elf's Calories
calories = {}
current_elf = ""

# Keep track of the current Elf index
elf_index = 0

# Iterate over each line of input
lines.each do |line|
  if line.empty?
    # If the line is empty, it marks the end of an Elf's inventory
    # Set the current Elf to the empty string to indicate that no Elf is currently being processed
    current_elf = ""
  elsif current_elf.empty?
    # If the current Elf is not set, this line must contain the number of Calories for the food
    # Initialize the Elf's Calories to the number on this line
    elf_index += 1
    current_elf = "Elf #{elf_index}"
    calories[current_elf] = line.to_i
  else
    # Otherwise, this line must contain the number of Calories for the current Elf's food
    # Add the Calories to the Elf's total
    calories[current_elf] += line.to_i
  end
end

# Sort the Elves by the number of Calories they are carrying, from most to least
calories = calories.sort_by { |elf, calories| -calories }

# Print the names and number of Calories carried by the top three Elves
puts "The top three Elves are:"
calories[0,3].each do |elf, calories|
  puts "#{elf}: #{calories} Calories"
end

# Calculate the total number of Calories carried by the top three Elves
total_calories = calories[0,3].inject(0) { |sum, (_, calories)| sum + calories }

# Print the total number of Calories carried by the top three Elves
puts "These Elves are carrying a total of #{total_calories} Calories"
