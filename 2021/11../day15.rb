# frozen_string_literal: true

require_relative '../../fwk'

DEST_COORDS = {}

class Node
  attr_reader :cost, :visited, :x, :y
  attr_accessor :tentative_cost

  def initialize(cost, x, y)
    @cost = cost
    @visited = false
    @tentative_cost = Float::INFINITY
    @x = x
    @y = y
  end

  def red
    printf
    yield
    printf "\033[0m"
  end

  def to_s
    @visited ? "\033[31m#{cost}\033[0m" : cost.to_s
  end

  def visited!
    @visited = true
  end

  def neighbors(grid)
    [[@x - 1, @y], [@x + 1, @y], [@x, @y - 1], [@x, @y + 1]].each_with_object([]) do |ij, arr|
      i, j = ij
      if ![i, j].any?(&:negative?) && grid[i]
        arr << grid[i][j]
      end
      arr
    end.compact
  end

  def estimated_remaining
    ((DEST_COORDS[:y] - y) + (DEST_COORDS[:x] - x)) * 5
  end

  def <=>(other)
    (tentative_cost + estimated_remaining) <=> (other.tentative_cost + other.estimated_remaining)
  end
end

def read_grid(file)
  lines = File.readlines(file)
  grid = lines.map.with_index { |line, x| line.strip.chars.map.with_index { |c, y| Node.new(c.to_i, x, y) } }

  init_x = grid.size
  init_y = grid.first.size
  new_x_size = grid.size * 5
  new_y_size = grid.size * 5

  (0..new_x_size - 1).each.with_index do |x|
    (0..new_y_size - 1).each.with_index do |y|
      grid[x] ||= Array.new(new_y_size)
      next if grid[x][y]

      prev_value = (y < init_y ? grid[x - init_x][y] : grid[x][y - init_y]).cost
      grid[x][y] = Node.new(prev_value % 9 + 1, x, y)
    end
  end
  grid
end

# class SortedNodes
#   def initialize
#     @array = []
#   end
#   def shift
#     @array.shift
#   end
#   def <<(node)
#     (0..).each do |i|
#       next if @array[i].tentative_cost > node.tentative_cost
#       @array.insert(i, node)
#     end
#   end
# end

def process(file)
  grid = read_grid(file)
  start = grid[0][0]
  start.tentative_cost = 0
  start.visited!
  dest = grid[-1][-1]
  DEST_COORDS[:x] = dest.x
  DEST_COORDS[:y] = dest.y
  unvisited = grid.size * grid.first.size

  next_in_line = Set.new([start])
  until next_in_line.empty?
    next_in_line = next_in_line.select { |n| !n.visited || n == start }.sort
    current_node = next_in_line.first
    if current_node
      next_in_line.delete(current_node)

      neighbors = current_node.neighbors(grid)
      neighbors.each do |neighbor|
        next if neighbor.visited
        neighbor.tentative_cost = [current_node.tentative_cost + neighbor.cost, neighbor.tentative_cost].min
        next_in_line << neighbor
      end
      current_node.visited!
      unvisited -= 1

      puts "unvisited: #{unvisited}" if unvisited % 100==0
      # puts grid.map { |row| row.map(&:to_s).join }.join("\n")
      # puts ''
    end
  end

  puts dest.tentative_cost
end

process('day15_sample.txt')
process('day15.txt')