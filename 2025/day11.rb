require_relative '../fwk'
require 'matrix'
require 'glpk'

class Node
  attr_accessor :name, :neighbors, :paths_count

  def initialize(name)
    self.name = name
    self.neighbors = []
    self.paths_count = {}
  end

  def compute_paths_count(not_visited)
    return paths_count[not_visited] if paths_count.key?(not_visited)

    return not_visited.empty? ? 1 : 0 if name == 'out'

    next_not_visited = not_visited.dup
    next_not_visited.delete(name)

    paths_count[not_visited] = neighbors.map do |neighbor| 
      neighbor.compute_paths_count(next_not_visited)
    end.sum
  end
end

lines = File.readlines(File.join(__dir__, 'input11.txt'), chomp: true)

devices_map = {}
devices_map['out'] = Node.new('out')
lines.each do |line|
  name, _neighbors_str = line.split(':')
  devices_map[name] = Node.new(name)
end

lines.each do |line| # rubocop:disable Style/CombinableLoops
  device_name, neighbors_str = line.split(':')
  neighbors = neighbors_str.split.map(&:strip).map { |name| devices_map[name] }
  device = devices_map[device_name]
  device.neighbors = neighbors
end

puts "part 1 : #{devices_map['you'].compute_paths_count([])}"
puts "part 2 : #{devices_map['svr'].compute_paths_count(['dac', 'fft'])}"
