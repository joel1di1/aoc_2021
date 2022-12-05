# frozen_string_literal: true

require 'set'

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
visited = Set.new

# Perform the movements
stop = false
movements.each do |movement|
  break if stop

  direction, distance = movement
  case dir
  when :north
    dir = (direction == 'L' ? :west : :east)
    dx = (direction == 'L' ? -1 : 1)
    (1..distance).each do |_i|
      x += dx
      if visited.include?([x, y])
        stop = true
        break
      else
        visited.add([x, y])
      end
    end
  when :south
    dir = (direction == 'L' ? :east : :west)
    dx = (direction == 'L' ? 1 : -1)
    (1..distance).each do |_i|
      x += dx
      if visited.include?([x, y])
        stop = true
        break
      else
        visited.add([x, y])
      end
    end
  when :west
    dir = (direction == 'L' ? :south : :north)
    dy = (direction == 'L' ? 1 : -1)
    (1..distance).each do |_i|
      y += dy
      if visited.include?([x, y])
        stop = true
        break
      else
        visited.add([x, y])
      end
    end
  when :east
    dir = (direction == 'L' ? :north : :south)
    dy = (direction == 'L' ? -1 : 1)
    (1..distance).each do |_i|
      y += dy
      if visited.include?([x, y])
        stop = true
        break
      else
        visited.add([x, y])
      end
    end
  end
end

# Calculate the distance from the starting position
distance = x.abs + y.abs
puts distance
