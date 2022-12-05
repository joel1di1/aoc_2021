# frozen_string_literal: true

# Read the instructions from the file
instructions = File.read('day1.txt')

# Parse the instructions and convert them into a sequence of movements
movements = instructions.split(', ').map do |instruction|
  direction = instruction[0]
  distance = instruction[1..].to_i
  [direction, distance]
end

# Initialize the position and direction
x = 0
y = 0
dir = :north

# Perform the movements
movements.each do |movement|
  direction, distance = movement
  case dir
  when :north
    dir = (direction == 'L' ? :west : :east)
    x += (direction == 'L' ? -distance : distance)
  when :south
    dir = (direction == 'L' ? :east : :west)
    x += (direction == 'L' ? distance : -distance)
  when :west
    dir = (direction == 'L' ? :south : :north)
    y += (direction == 'L' ? distance : -distance)
  when :east
    dir = (direction == 'L' ? :north : :south)
    y += (direction == 'L' ? -distance : distance)
  end
end

# Calculate the distance from the starting position
distance = x.abs + y.abs
puts distance
