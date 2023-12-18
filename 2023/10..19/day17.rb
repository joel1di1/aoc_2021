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
    x == other.x && y == other.y && direction == other.direction
  end

  def eql?(other)
    self == other
  end

  def <=>(other)
    [x, y, direction] <=> [other.x, other.y, other.direction]
  end
end

class HeapElementWithDistance
  attr_reader :value, :priority, :distance

  def initialize(value, priority, distance)
    @value = value
    @priority = priority
    @distance = distance
  end

  def <=>(other)
    @priority <=> other.priority
  end

  def <=(other)
    @priority <= other.priority
  end

  def >=(other)
    @priority >= other.priority
  end

  def <(other)
    @priority < other.priority
  end

  def >(other)
    @priority > other.priority
  end
end

class PriorityQueueWithDistance
  def initialize
    @min_heap = MinHeap.new
  end

  def push(element, priority, distance)
    @min_heap << HeapElementWithDistance.new(element, priority, distance)
  end

  def pop
    element = @min_heap.pop
    [element.value, element.priority, element.distance]
  end

  def empty?
    @min_heap.empty?
  end

  def size
    @min_heap.size
  end

  def array
    @min_heap.array
  end
end





# // A* finds a path from start to goal.
# // h is the heuristic function. h(n) estimates the cost to reach goal from node n.
# function A_Star(start, goal, h)
#     // The set of discovered nodes that may need to be (re-)expanded.
#     // Initially, only the start node is known.
#     // This is usually implemented as a min-heap or priority queue rather than a hash-set.
#     openSet := {start}

#     // For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from the start
#     // to n currently known.
#     cameFrom := an empty map

#     // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
#     gScore := map with default value of Infinity
#     gScore[start] := 0

#     // For node n, fScore[n] := gScore[n] + h(n). fScore[n] represents our current best guess as to
#     // how cheap a path could be from start to finish if it goes through n.
#     fScore := map with default value of Infinity
#     fScore[start] := h(start)

#     while openSet is not empty
#         // This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
#         current := the node in openSet having the lowest fScore[] value
#         if current = goal
#             return reconstruct_path(cameFrom, current)

#         openSet.Remove(current)
#         for each neighbor of current
#             // d(current,neighbor) is the weight of the edge from current to neighbor
#             // tentative_gScore is the distance from start to the neighbor through current
#             tentative_gScore := gScore[current] + d(current, neighbor)
#             if tentative_gScore < gScore[neighbor]
#                 // This path to neighbor is better than any previous one. Record it!
#                 cameFrom[neighbor] := current
#                 gScore[neighbor] := tentative_gScore
#                 fScore[neighbor] := tentative_gScore + h(neighbor)
#                 if neighbor not in openSet
#                     openSet.add(neighbor)

#     // Open set is empty but goal was never reached
#     return failure

def a_star(start_x, start_y, debug_every: nil)
  # The set of discovered nodes that may need to be (re-)expanded.
  # Initially, only the start node is known.
  # This is usually implemented as a min-heap or priority queue rather than a hash-set.
  open_set = PriorityQueueWithDistance.new

  # For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from the start
  # to n currently known.
  came_from = {}

  # For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
  g_score = Hash.new(Float::INFINITY)
  start1 = Node.new(start_x, start_y, :right, 3)
  start2 = Node.new(start_x, start_y, :down, 3)
  g_score[start1] = 0
  g_score[start2] = 0

  # For node n, fScore[n] := gScore[n] + h(n). fScore[n] represents our current best guess as to
  # how cheap a path could be from start to finish if it goes through n.
  f_score = Hash.new(Float::INFINITY)
  f_score[start1] = 0
  f_score[start2] = 0

  # The set of discovered nodes that may need to be (re-)expanded.
  # Initially, only the start node is known.
  # This is usually implemented as a min-heap or priority queue rather than a hash-set.
  open_set.push(start1, 0, 0)
  open_set.push(start2, 0, 0)

  iter = 0

  until open_set.empty?
    # This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
    current, priority, distance = open_set.pop
    puts "iter: #{iter}, open_set size: #{open_set.size}, current node: #{current}, f_score: #{f_score[current]}" if debug_every && iter % debug_every == 0

    # If the current node is the end node, return the distance
    return f_score[current] if current.end?

    current.neighbors.each do |neighbor|
      # d(current,neighbor) is the weight of the edge from current to neighbor
      # tentative_gScore is the distance from start to the neighbor through current
      tentative_g_score = g_score[current] + neighbor.inner_cost

      next unless tentative_g_score < g_score[neighbor]

      # This path to neighbor is better than any previous one. Record it!
      came_from[neighbor] = current
      g_score[neighbor] = tentative_g_score
      f_score[neighbor] = tentative_g_score + (GRID.size - neighbor.x - 1) + (GRID[0].size - neighbor.y - 1)
      open_set.push(neighbor, f_score[neighbor], g_score[neighbor])
    end
    iter += 1
  end

  # Open set is empty but goal was never reached
  nil
end

res = a_star(0, 0, debug_every: 100000)

puts res

