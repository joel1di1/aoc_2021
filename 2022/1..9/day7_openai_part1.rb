# frozen_string_literal: true

class TreeNode
  attr_accessor :name, :size, :children, :parent

  def initialize(name, size = 0)
    @name = name
    @size = size
    @children = {}
    @parent = nil
  end

  def total_size
    size + children.values.map(&:total_size).sum
  end
end
def parse_input(input)
  current_node = TreeNode.new('/')
  root = current_node
  input.each_line do |line|
    line.strip!
    next if line.empty?

    case line
    when /^\$ cd (.+)$/
      dir = $1
      if dir == '/'
        current_node = root
      elsif dir == '..'
        current_node = current_node.parent
      else
        current_node = current_node.children[dir]
      end
    when /^\$ ls$/
      # Do nothing
    when /^(dir|[\d]+) (.+)$/
      size_or_dir, name = $1, $2
      if size_or_dir == 'dir'
        new_node = TreeNode.new(name)
        new_node.parent = current_node
        current_node.children[name] = new_node
      else
        size = size_or_dir.to_i
        current_node.children[name] = TreeNode.new(name, size)
      end
    end
  end
  root
end

def find_directories_with_size_at_most(node, max_size)
  return [] unless node

  dirs = []
  if !node.children.empty? && node.total_size <= max_size
    dirs << node
  end
  dirs += node.children.values.flat_map { |child| find_directories_with_size_at_most(child, max_size) }
  dirs
end


input = File.read('day7.txt')
root = parse_input(input)
directories_with_size_at_most_100000 = find_directories_with_size_at_most(root, 100_000)
total_size = directories_with_size_at_most_100000.map(&:total_size).sum
puts "Sum of the total sizes of directories with size at most 100,000: #{total_size}"

def find_smallest_directory_to_delete(node, required_space)
  return nil unless node

  directory_to_delete = nil
  if !node.children.empty? && node.total_size >= required_space
    directory_to_delete = node
  end

  node.children.values.each do |child|
    child_directory_to_delete = find_smallest_directory_to_delete(child, required_space)
    if child_directory_to_delete && (!directory_to_delete || child_directory_to_delete.total_size < directory_to_delete.total_size)
      directory_to_delete = child_directory_to_delete
    end
  end

  directory_to_delete
end

total_disk_space = 70_000_000
used_space = root.total_size
unused_space = total_disk_space - used_space
required_space_for_update = 30_000_000
additional_space_needed = required_space_for_update - unused_space

smallest_directory_to_delete = find_smallest_directory_to_delete(root, additional_space_needed)

if smallest_directory_to_delete
  puts "The smallest directory to delete is '#{smallest_directory_to_delete.name}' with a total size of #{smallest_directory_to_delete.total_size}."
else
  puts "No suitable directory found to delete."
end
