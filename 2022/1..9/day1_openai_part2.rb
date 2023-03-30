elf_calories = []
current_elf_calories = 0

File.foreach('day1.txt') do |line|
  if line.strip.empty?
    elf_calories << current_elf_calories
    current_elf_calories = 0
  else
    current_elf_calories += line.strip.to_i
  end
end

# add the last Elf's total Calories
elf_calories << current_elf_calories

# find the top three Elves
top_elves = elf_calories.sort.reverse.take(3)

# calculate the total Calories carried by the top three Elves
total_calories = top_elves.sum

puts "The top three Elves are carrying a total of #{total_calories} Calories"
