# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

GRID = File.readlines("#{__dir__}/input17.txt", chomp: true).map { |line| line.chars.map(&:to_i).freeze }.freeze

class Node
  attr_reader :x, :y, :direction, :direction_left, :inner_cost

  def initialize(x, y, direction, direction_left)
    @x = x
    @y = y
    @direction = direction
    @direction_left = direction_left
    @inner_cost = GRID[x][y] if GRID[x]
  end

  def end?
    x == GRID.size - 1 && y == GRID[0].size - 1
  end

  def neighbors
    neighbors_tmp = case direction
                    when :up
                      [
                        Node.new(x, y - 1, :left, 3), # left, change direction, 3 steps to go
                        Node.new(x, y + 1, :right, 3), # right, change direction, 3 steps to go
                        Node.new(x - 1, y, :up, direction_left - 1) # up, same direction, decrease steps to go in this direction
                      ]
                    when :down
                      [
                        Node.new(x, y - 1, :left, 3), # left, change direction, 3 steps to go
                        Node.new(x, y + 1, :right, 3), # right, change direction, 3 steps to go
                        Node.new(x + 1, y, :down, direction_left - 1) # down, same direction, decrease steps to go in this direction
                      ]
                    when :left
                      [
                        Node.new(x - 1, y, :up, 3), # up, change direction, 3 steps to go
                        Node.new(x + 1, y, :down, 3), # down, change direction, 3 steps to go
                        Node.new(x, y - 1, :left, direction_left - 1) # left, same direction, decrease steps to go in this direction
                      ]
                    when :right
                      [
                        Node.new(x - 1, y, :up, 3), # up, change direction, 3 steps to go
                        Node.new(x + 1, y, :down, 3), # down, change direction, 3 steps to go
                        Node.new(x, y + 1, :right, direction_left - 1) # right, same direction, decrease steps to go in this direction
                      ]
                    end

    neighbors_tmp.reject { |neighbor| neighbor.x < 0 || neighbor.y < 0 || neighbor.x >= GRID.size || neighbor.y >= GRID[0].size || neighbor.direction_left < 0 }
  end

  def cost(neighbor)
    neighbor.inner_cost
  end

  def to_s
    "Node: (#{x}, #{y})(#{@inner_cost}) #{direction} #{direction_left}"
  end

  def inspect
    to_s
  end

  def ==(other)
    x == other.x && y == other.y && direction == other.direction && direction_left == other.direction_left
  end

  def eql?(other)
    self == other
  end

  def <=>(other)
    [x, y, direction, direction_left] <=> [other.x, other.y, other.direction, other.direction_left]
  end
end


# find the shortest path between two nodes in a graph
# Nodes must respond to #neighbors and #cost(neighbor)
def adpated_dijkstra(start_x, start_y, debug_every: nil)
  # Create a set to store the nodes that have been visited
  visited = Set.new

  # Create a priority queue to store the nodes that need to be processed
  # The priority queue will be sorted by the distance from the start node
  pq = PriorityQueue.new

  # Add the start node to the priority queue with a distance of 0
  pq.push(Node.new(start_x, start_y, :down, 3), 0)
  pq.push(Node.new(start_x, start_y, :right, 3), 0)

  iter = 0

  # While there are nodes in the priority queue
  until pq.empty?
    # Get the node with the smallest distance from the priority queue
    current_node, distance = pq.pop
    puts "iter: #{iter}, pq size: #{pq.size}, current node: #{current_node}, distance: #{distance}" if debug_every && iter % debug_every == 0

    # If the current node is the end node, return the distance
    return distance + current_node.inner_cost if current_node.end?

    # Mark the current node as visited
    # puts "visited: #{visited}"
    visited.add(current_node)

    # For each neighbor of the current node
    current_node.neighbors.each do |neighbor|
      # If the neighbor has not been visited
      # puts "neighbor: #{neighbor}"
      next if visited.include?(neighbor)

      # Calculate the distance to the neighbor as the distance to the current node plus the cost of the edge between the current node and the neighbor
      neighbor_distance = distance + current_node.cost(neighbor)

      # Add the neighbor to the priority queue with the calculated distance
      # puts "pushing neighbor: #{neighbor}, distance: #{neighbor_distance}"
      pq.push(neighbor, neighbor_distance)
    end
    iter += 1

  end

  # If the end node was not reached, return nil
  nil
end

res = adpated_dijkstra(0, 0, debug_every: 10000)
puts "res: #{res}"
