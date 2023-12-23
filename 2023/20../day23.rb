# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

grid = File.readlines('input23.txt', chomp: true).map(&:chars)

# convert grid to hash
GRID_H = {}

grid.each_with_index do |row, x|
  row.each_with_index do |cell, y|
	GRID_H[[x, y]] = cell
  end
end

# find coords of '.' in the first line
grid.first.each_with_index do |cell, y|
	if cell == '.'
  	START_NODE = [0, y]
  	break
  end
end

grid.last.each_with_index do |cell, y|
  if cell == '.'
    END_NODE = [grid.size - 1, y]
    break
  end
end

def neighbours(node)
  [[node[0] + 1, node[1]], [node[0], node[1] + 1], [node[0], node[1] - 1], [node[0] - 1, node[1]]]
    .select { |next_node| GRID_H[next_node] && GRID_H[next_node] != '#' }
end

class Vertex
  attr_reader :coords, :neighbours

  def initialize(coords)
    @coords = coords
    @neighbours = []
  end

  def add_neighbour(neighbour, cost)
    @neighbours << [neighbour, cost]
  end
end

# find vertices
vertices = GRID_H.select do |coords, cell|
  [START_NODE, END_NODE].include?(coords) || (cell != '#' && neighbours(coords).size > 2)
end.keys

vertices_set = Set.new(vertices)

# link adjacents vertices
vertices_with_nightbors = vertices.map do |coords|
  [coords, neighbours(coords).map do |neighbour|
    cost = 1
    visited = Set.new
    visited << coords
    until vertices_set.include?(neighbour) || [START_NODE, END_NODE].include?(neighbour)
      visited << neighbour
      neighbours_to_check = neighbours(neighbour)
      debugger if (neighbours_to_check.reject{|n| visited.include?(n)}).size > 1
      neighbour = (neighbours_to_check.reject{|n| visited.include?(n)}).first
      cost += 1 
    end
    [neighbour, cost]
  end]
end

# vertices_with_nightbors.each do |coords, neighbours|
#   puts "#{coords} -> #{neighbours.inspect}"
# end

paths = [[[START_NODE, 0]]]

possible_paths = []

max_path_cost = 0

iter = 0

until paths.empty?
  iter += 1
  path = paths.shift

  puts "#{iter} | #{paths.size} | path: #{path.inspect}" if iter % 100_000 == 0

  vertex = vertices_with_nightbors.find { |coords, _| coords == path.last.first }

  if vertex.first == END_NODE
    possible_paths << path
    cost = path.map(&:last).inject(:+)
    if cost > max_path_cost
      puts "Found path: #{cost}" 
      max_path_cost = cost
    end
    next
  end

  vertex.last.select { |neighbour, _| !path.map(&:first).include?(neighbour) }.each do |neighbour, cost|
    paths << path + [[neighbour, cost]]
  end
end

puts(possible_paths.map do |path|
  path.map(&:last).inject(:+)
end.max)