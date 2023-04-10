# advent of code 2022 day 1 
# --- part 1

# Read input from day1.txt
# Read input from day1.txt
input = File.read("day1.txt")

# lines are separated by a blank line
# so we can split the lines into groups by splitting on the blank line
groups = input.split("\n\n")

# for each group, sum the numbers in the group
# then find the bigger group
biggest_group = groups.map do |group|
  group.split.map(&:to_i).sum
end.max

# print the biggest group
puts "Part 1: The Elf carrying the most Calories is carrying #{biggest_group} Calories"


# --- part 2

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

# Calculate the total number of Calories carried by the top three Elves
total_calories = calories[0,3].inject(0) { |sum, (_, calories)| sum + calories }

# Print the total number of Calories carried by the top three Elves
puts "Part 2: The top three Elves carrying the most Calories are carrying a total of #{total_calories} Calories"
