require 'set'

# Read the input from the file "day12.txt"
input = File.read("day12.txt")

# Split the input into an array of lines
lines = input.split("\n")

# Find the starting position
start_x = lines.map { |line| line.index("S") }.compact.first
start_y = lines.index { |line| line.include?("S") }

# Find the ending position
end_x = lines.map { |line| line.index("E") }.compact.first
end_y = lines.index { |line| line.include?("E") }

# Initialize the queue with the starting position
queue = [[start_x, start_y, 0]]

# Initialize a set to store the visited positions
visited = Set.new

# Initialize a variable to store the result
result = nil

# Loop until the queue is empty
while !queue.empty?
  # Get the next position from the queue
  x, y, steps = queue.shift

  # If the position is the ending position, set the result and break
  if x == end_x && y == end_y
    result = steps
    break
  end

  # Add the current position to the visited set
  visited.add([x, y])

  # Check all possible moves
  [[0, 1], [0, -1], [1, 0], [-1, 0]].each do |dx, dy|
    # Calculate the new position
    new_x, new_y = x + dx, y + dy

    # Skip this move if it's out of bounds or has already been visited
    next if new_x < 0 || new_y < 0 || new_x >= lines[0].length || new_y >= lines.length || visited.include?([new_x, new_y])

    # Calculate the elevation difference between the current position and the new position
    elevation_difference = lines[y][x].ord - lines[new_y][new_x].ord

    # Skip this move if the elevation difference is too large
    next if elevation_difference.abs > 1

    # Add the new position to the queue
    queue << [new_x, new_y, steps + 1]
  end
end

# Print the result
puts result
