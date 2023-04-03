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

max_calories = elf_calories.max
max_calories_elf = elf_calories.index(max_calories) + 1

puts "Elf #{max_calories_elf} is carrying the most Calories: #{max_calories}"

  