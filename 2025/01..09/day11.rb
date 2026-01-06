require_relative '../../fwk'
require 'set'

# Represents a directed graph of devices and their connections
class DeviceGraph
  attr_reader :adjacency_list

  def initialize(adjacency_list)
    @adjacency_list = adjacency_list
  end

  # Find all paths from start_node to end_node using DFS
  # Returns count only (doesn't store paths)
  def count_all_paths(start_node, end_node)
    count_paths_dfs(start_node, end_node, Set.new([start_node]))
  end

  # Count paths from start to end that visit all required nodes
  def count_paths_visiting(start_node, end_node, required_nodes)
    required_set = Set.new(required_nodes)
    visited_required = required_set.include?(start_node) ? Set.new([start_node]) : Set.new
    count_paths_with_required(start_node, end_node, Set.new([start_node]), required_set, visited_required)
  end

  private

  # Fast DFS that only counts paths (doesn't store them)
  def count_paths_dfs(current_node, end_node, visited_set)
    return 1 if current_node == end_node
    return 0 unless adjacency_list[current_node]

    total = 0
    adjacency_list[current_node].each do |neighbor|
      next if visited_set.include?(neighbor)

      visited_set.add(neighbor)
      total += count_paths_dfs(neighbor, end_node, visited_set)
      visited_set.delete(neighbor)
    end

    total
  end

  # DFS that counts paths visiting all required nodes
  def count_paths_with_required(current_node, end_node, visited_set, required_set, visited_required)
    if current_node == end_node
      return visited_required.size == required_set.size ? 1 : 0
    end

    return 0 unless adjacency_list[current_node]

    total = 0
    adjacency_list[current_node].each do |neighbor|
      next if visited_set.include?(neighbor)

      # Track if this neighbor is a required node
      new_visited_required = visited_required.dup
      new_visited_required.add(neighbor) if required_set.include?(neighbor)

      visited_set.add(neighbor)
      total += count_paths_with_required(neighbor, end_node, visited_set, required_set, new_visited_required)
      visited_set.delete(neighbor)
    end

    total
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

# Part 1: Count all paths from 'you' to 'out'
part1 = graph.count_all_paths('you', 'out')
puts "Part 1: #{part1}"

# Part 2: Count paths from 'svr' to 'out' that visit both 'dac' and 'fft'
part2 = graph.count_paths_visiting('svr', 'out', ['dac', 'fft'])
puts "Part 2: #{part2}"
