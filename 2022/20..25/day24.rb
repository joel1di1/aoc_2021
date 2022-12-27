require 'byebug'
require 'set'
require_relative '../../fwk'

class Map
  attr_reader :height, :width, :depth

  def initialize(height, width, depth, hashmap: {})
    @hashmap = hashmap
    @width = width
    @height = height
    @depth = depth
  end

  def dup(new_current_coords)
    Map.new(@height, @width, hashmap: @hashmap)
  end

  def [](x, y)
    @hashmap[[x, y]]
  end

  def []=(x, y, value)
    @hashmap[[x, y]] ||= []
    @hashmap[[x, y]] << value
  end

  def size
    @hashmap.size
  end

  def self.from_file(file)
    lines = File.readlines(file).map(&:chomp)
    map = Map.new(lines.size, lines.first.size, 0)
    File.readlines(file).each_with_index.map do |line, x|
      line.chars.each_with_index.map do |char, y|
        map[x, y] = char if char != '.'
      end
    end
    map
  end

  def display(current_coords = [0, 1], target_coords = [height-1, width-2])
    (0..@height-1).each do |x|
      (0..@width-1).each do |y|
        elements = @hashmap[[x, y]]
        if elements
          print(elements.size > 1 ? elements.size : elements.first)
        else
          if current_coords == [x, y]
            print('E')
          elsif target_coords == [x, y]
            print('T')
          else
            print('.')
          end
        end
      end
      puts
    end
  end

  def next_map
    next_map_local = Map.new(@height, @width, @depth+1)
    @hashmap.each do |coords, elements|
      x, y = coords

      elements.each do |element|
        case element
        when '^'
          # if reach wall, start from opposite wall
          next_x = x == 1 ? @height-2 : x-1
          next_map_local[next_x, y] = '^'
        when 'v'
          next_x = x == @height-2 ? 1 : x + 1
          next_map_local[next_x, y] = 'v'
        when '<'
          next_y = y == 1 ? @width-2 : y-1
          next_map_local[x, next_y] = '<'
        when '>'
          next_y = y == @width-2 ? 1 : y + 1
          next_map_local[x, next_y] = '>'
        when '#'
          next_map_local[x, y] = '#'
        end
      end
    end
    next_map_local
  end
end

def solve_part1(file)
  current_map = Map.from_file(file)

  start_node = [0, 1]
  target_node = [current_map.height-1, current_map.width-2]

  depth, current_map = solve(current_map, start_node, target_node)
  puts "Part 1 #{file}: #{depth}"
end

def solve(current_map, start_node, target_node)
  reachable_nodes = Set.new
  reachable_nodes << start_node

  depth = 0

  until reachable_nodes.include?(target_node) || reachable_nodes.empty?
    depth += 1
    # puts "Depth: #{depth}, reachable nodes: #{reachable_nodes}"

    current_map = current_map.next_map

    new_reachable_nodes = Set.new

    reachable_nodes.each do |x, y|
      [[-1, 0], [0, 0], [1, 0], [0, 1], [0, -1]].each do |dx, dy|
        next if x + dx < 0
  
        next_x, next_y = [x+dx, y+dy]
        next if current_map[next_x, next_y]
  
        new_reachable_nodes << [next_x, next_y]
      end
    end

    reachable_nodes = new_reachable_nodes
  end

  [depth, current_map]
end

def solve_part2(file)
  current_map = Map.from_file(file)

  start_node = [0, 1]
  target_node = [current_map.height-1, current_map.width-2]

  depth = 0

  # first trip
  depth_tmp, current_map = solve(current_map, start_node, target_node)
  depth += depth_tmp

  # back trip
  depth_tmp, current_map = solve(current_map, target_node, start_node)
  depth += depth_tmp

  # last trip
  depth_tmp, current_map = solve(current_map, start_node, target_node)
  depth += depth_tmp
  

  puts "Part 2 #{file}: #{depth}"
end

solve_part1('day24_sample.txt')
solve_part1('day24.txt')

solve_part2('day24_sample.txt')
solve_part2('day24.txt')
