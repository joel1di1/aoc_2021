# frozen_string_literal

require 'byebug'

class Edge
  attr_accessor :from, :to, :weight

  def initialize(from, to, weight)
    @from = from
    @to = to
    @weight = weight
  end

end

class Node
  attr_accessor :name, :edges, :distance, :previous

  def initialize(name)
    @name = name
    @edges = []
  end
  
  def add_edge(edge)
    @edges << edge
  end

  def to_s
    "#{name} (#{distance}) -> #{edges.map(&:to).map(&:name).join(', ')}"
  end
end

# input is an array of caracter arrays
# each caracter array is a line of the input
# each caracter is a node
# nodes are connected if they are adjacent and target node is on letter more maximum
# return a hash of nodes
def parse_input(input)
  nodes = {}
  input.each_with_index do |line, x|
    line.each_with_index do |char, y|
      name = "(#{x},#{y})-#{char} "
      node = nodes[name] ||= Node.new(name)

      # check the 4 adjacent nodes
      neighbors = [ [x-1, y], [x+1, y], [x, y-1], [x, y+1] ].select do |x1, y1|
        x1 >= 0 && y1 >= 0 && x1 < input.size && y1 < line.size
      end
      # and if the target node is on letter more maximum
      neighbors.select! do |x1, y1|
        (input[x1][y1].ord - char.ord) <= 1
      end
      # add an edge to the node
      neighbors.each do |x1, y1|
        neighbor_name = "(#{x1},#{y1})-#{input[x1][y1]} "
        neighbor = nodes[neighbor_name] ||= Node.new(neighbor_name)
        weight = 1
        edge = Edge.new(node, neighbor, weight)
        node.add_edge(edge)
      end
    end
  end

  nodes
end


# given a list of nodes, find the shortest path between two nodes
def dijkstra(nodes, start, finish)
  # initialize the distance to all nodes to infinity
  nodes.each do |name, node|
    node.distance = Float::INFINITY
  end
  # initialize the distance to the start node to 0
  start.distance = 0

  # while there are still nodes to visit
  while nodes.any?
    # find the node with the shortest distance
    current_node = nodes.values.min_by(&:distance)
    # for each neighbor of the current node
    current_node.edges.each do |edge|
      neighbor = edge.to
      # if the distance to the neighbor is shorter by going through the current node
      if neighbor.distance > current_node.distance + edge.weight
        # update the distance to the neighbor
        neighbor.distance = current_node.distance + edge.weight
        # and set the previous node
        neighbor.previous = current_node
      end
    end
    # remove the current node from the list of nodes to visit
    nodes.delete(current_node.name)
  end
  # return the distance to the finish node
  finish.distance
end

# find element in the input
def coords(input, char)
  input.each_with_index do |line, x|
    line.each_with_index do |c, y|
      return [x, y] if c == char
    end
  end
end

input = File.readlines('day12.txt').map(&:strip).map do |line|
  line.chars
end

start_coords = coords(input, 'S')
exit_coords = coords(input, 'E')

input[start_coords[0]][start_coords[1]] = 'a'
input[exit_coords[0]][exit_coords[1]] = 'z'

nodes = parse_input(input)
start_node = nodes["(#{start_coords[0]},#{start_coords[1]})-a "]
exit_node = nodes["(#{exit_coords[0]},#{exit_coords[1]})-z "]

puts "part1: #{dijkstra(nodes, start_node, exit_node)}"

# part 2
path_starting_with_a = {}

# list_every_start
starts = []
input.each_with_index do |line, x|
  line.each_with_index do |char, y|
    starts << [x, y] if char == 'a'
  end
end

puts "number of starts: #{starts.size}"

min = starts.map do |x, y|
  puts "start: #{x}, #{y}"
  nodes = parse_input(input)
  exit_node = nodes["(#{exit_coords[0]},#{exit_coords[1]})-z "]
  start_node = nodes["(#{x},#{y})-a "]
  path_starting_with_a[start_node] = dijkstra(nodes, start_node, exit_node)
end.min

puts "part2: #{min}"