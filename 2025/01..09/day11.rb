require_relative '../../fwk'

# Represents a directed graph of devices and their connections
class DeviceGraph
  attr_reader :adjacency_list

  def initialize(adjacency_list)
    @adjacency_list = adjacency_list
  end

  # Find all paths from start_node to end_node using DFS
  def count_all_paths(start_node, end_node)
    all_paths = []
    find_all_paths(start_node, end_node, [start_node], all_paths)
    all_paths.size
  end

  # Find all paths and return them (useful for debugging)
  def find_all_paths_list(start_node, end_node)
    all_paths = []
    find_all_paths(start_node, end_node, [start_node], all_paths)
    all_paths
  end

  private

  # DFS with backtracking to find all paths
  def find_all_paths(current_node, end_node, current_path, all_paths)
    # Base case: reached the end
    if current_node == end_node
      all_paths << current_path.dup
      return
    end

    # No outgoing edges
    return unless adjacency_list[current_node]

    # Explore all neighbors
    adjacency_list[current_node].each do |neighbor|
      # Avoid cycles by not revisiting nodes in current path
      next if current_path.include?(neighbor)

      current_path.push(neighbor)
      find_all_paths(neighbor, end_node, current_path, all_paths)
      current_path.pop
    end
  end
end

# Parse input file
# Format: device_name: output1 output2 ...
def parse_input(filename)
  adjacency_list = {}

  File.readlines(File.join(__dir__, filename), chomp: true).each do |line|
    # Parse "device: output1 output2 ..."
    device, outputs = line.split(': ')
    adjacency_list[device] = outputs.split
  end

  DeviceGraph.new(adjacency_list)
end

# Solve actual puzzle
graph = parse_input('input11.txt')

part1 = graph.count_all_paths('you', 'out')
puts "Part 1: #{part1}"
