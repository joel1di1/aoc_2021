# Read the input from the file `day1.txt`
input = File.read("day1.txt")

# Initialize the floor variable to 0 and the position variable to 1
floor = 0
position = 1

# Iterate over each character in the input
input.each_char do |char|
  # Increment the floor variable by 1 if the character is `(`
  # Decrement the floor variable by 1 if the character is `)`
  floor += 1 if char == "("
  floor -= 1 if char == ")"

  # If the floor is -1, print the current position and exit the loop
  if floor == -1
    puts position
    break
  end

  # Increment the position variable by 1
  position += 1
end
