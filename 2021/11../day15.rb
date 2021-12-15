# frozen_string_literal: true

require_relative '../../fwk'

class Node
  attr_reader :cost, :visited
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

  def <=>(other)
    self.tentative_cost <=> other.tentative_cost
  end
end

def process(file)
  lines = File.readlines(file)
  grid = lines.map.with_index { |line, x| line.strip.chars.map.with_index { |c, y| Node.new(c.to_i, x, y) } }
  start = grid[0][0]
  start.tentative_cost = 0
  start.visited!
  dest = grid[-1][-1]
  unvisited = Set.new(grid.flatten)

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
      unvisited.delete(current_node)
      # puts grid.map { |row| row.map(&:to_s).join }.join("\n")
      # puts ''
    end
  end

  puts dest.tentative_cost
end

process('day15_sample.txt')
process('day15.txt')