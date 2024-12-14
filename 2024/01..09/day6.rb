require 'byebug'

lines = File.readlines(File.join(__dir__, 'input6.txt')).map(&:strip)

grid = {}

initial_position = nil

(0..lines.size-1).each do |i|
  line = lines[i]
  (0..line.size-1).each do |j|
    case line[j]
    when '#'
      grid[[i, j]] = '#'
    when '.'
      grid[[i, j]] = '.'
    when '^'
      grid[[i, j]] = '.'
      initial_position = [i, j]
    end
  end
end

puts "initial_position: #{initial_position}"

guard_positions = []

ADDS = {
  north: [-1, 0],
  south: [1, 0],
  east: [0, 1],
  west: [0, -1]
}

next_direction = {
  north: :east,
  east: :south,
  south: :west,
  west: :north
}

current_position = initial_position
current_direction = :north

def next_position(current_position, current_direction)
  current_position.map.with_index do |pos, i|
    pos + ADDS[current_direction][i]
  end
end

def next_position_valid(current_position, current_direction, grid)
  next_pos = next_position(current_position, current_direction)
  '#' != grid[next_pos]
end

while grid[current_position]
  puts "current_position: #{current_position}, current_direction: #{current_direction}"
  guard_positions << current_position

  until next_position_valid(current_position, current_direction, grid)
    current_direction = next_direction[current_direction]
  end

  current_position = next_position(current_position, current_direction)
end

puts "part1: #{guard_positions.uniq.size}"
