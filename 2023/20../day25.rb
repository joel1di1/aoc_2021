# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

class Node
  attr_reader :name, :neighbours, :group, :id

  def initialize(id, name)
    @name = name
    @neighbours = Set.new
    @id = id
    @group = nil
  end

  def add_neighbour(node)
    @neighbours << node
  end

  def to_s
    name
  end

  def inspect
    to_s
  end

  def group=(group)
    @group = group
  end

  def link_with_other_group
    neighbours.count { |n| n.group != group }
  end

  def link_with_group
    neighbours.count { |n| n.group == group }
  end

  def link_ratio
    link_with_other_group - link_with_group
  end

  def change_group!
    @group = group == :group1 ? :group2 : :group1
  end
end

lines = File.readlines('input25.txt', chomp: true)

nodes = {}

n_id = 1

lines.each do |line|
  name, neighbours = line.split(':')
  nodes[name] = Node.new(n_id, name)
  n_id += 1

  neighbours.split().map do |neighbour_name|
    if nodes[neighbour_name].nil?
      nodes[neighbour_name] = Node.new(n_id, neighbour_name)
      n_id += 1
    end
  end
end

lines.each do |line|
  name, neighbours_str = line.split(':')
  node = nodes[name]

  neighbours_str.split().each do |neighbour|
    node.add_neighbour(nodes[neighbour])
    nodes[neighbour].add_neighbour(node)
  end
end

# nodes.each_with_index do |(_name, node), i|
#   node.group = i.even? ? :group1 : :group2
# end

all_nodes = nodes.values

# write all nodes in file
File.open('nodes.csv', 'w') do |f|
  f.puts 'Id,Label'
  all_nodes.each do |node|
    f.puts "#{node.id},#{node.name}"
  end
end

File.open('edges.csv', 'w') do |f|
  f.puts 'Source,Target,Type'
  all_nodes.each do |node|
    node.neighbours.each do |neighbour|
      f.puts "#{node.id},#{neighbour.id},Undirected"
    end
  end
end


# group1
# xvp, vfs, pbq
group1 = []
['xvp', 'vfs', 'pbq'].each do |name|
  nodes[name].group = :group1
  group1 << nodes[name]
end

# group2 
# zpc, nzn, dhl
['zpc', 'nzn', 'dhl'].each do |name|
  nodes[name].group = :group2
end

# add all nodes to group1
until group1.empty?
  node = group1.shift
  node.neighbours.each do |neighbour|
    if neighbour.group.nil?
      neighbour.group = :group1
      group1 << neighbour
    end
  end
end

group1_size = all_nodes.count { |n| n.group == :group1 }
group2_size = all_nodes.count { |n| n.group != :group1 }

puts "group1 size: #{group1_size}"
puts "group2 size: #{group2_size}"
puts "mult: #{group1_size * group2_size}"


# # count links between 2 groups (:group1, :group2)
# puts all_nodes.map(&:link_with_other_group).sum / 2

# # find the node with the most links between 2 groups
# node_to_change = all_nodes.max_by(&:link_with_other_group)

# node_to_change.change_group!

# puts all_nodes.map(&:link_with_other_group).sum / 2

# step = 100_000
# last_3_counts = []
# links_count = all_nodes.map(&:link_with_other_group).sum / 2
# until links_count == 3 || step == 0
#   node_to_change = all_nodes.max_by(&:link_ratio)
#   node_to_change.change_group!
#   last_3_counts << links_count
#   last_3_counts.shift if last_3_counts.size > 3

#   links_count = all_nodes.map(&:link_with_other_group).sum / 2

#   # if already seen, shuffle groups
#   if last_3_counts.size == 3 && last_3_counts.include?(links_count)
#     puts 'shuffle groups'
#     all_nodes.each do |node|
#       node.group = Random.rand < 0.5 ? :group1 : :group2
#     end
#     links_count = all_nodes.map(&:link_with_other_group).sum / 2
#     last_3_counts = []
#   end

#   step -= 1
#   puts "step: #{step}, #{links_count}" if step % 1000 == 0
# end

# puts "resulting links: #{all_nodes.map(&:link_with_other_group).sum / 2}"

# # count nodes in groups and multiply the size of groups
# puts all_nodes.group_by(&:group).map { |_k, v| v.size }.reduce(&:*)