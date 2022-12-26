require 'byebug'
require 'set'
require_relative '../../fwk'

class Map

  CACHE = {}

  attr_reader :current_coords, :target_coords, :cost

  def initialize(height, width, current_coords: nil, hashmap: {}, cost: 0)
    @hashmap = hashmap
    @width = width
    @height = height
    @current_coords = current_coords
    @target_coords = [@height-1, @width-2]
    @cost = cost
  end

  def dup(new_current_coords)
    Map.new(@height, @width, current_coords: new_current_coords, hashmap: @hashmap, cost: @cost)
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
    map = Map.new(lines.size, lines.first.size, current_coords: [0, 1])
    File.readlines(file).each_with_index.map do |line, x|
      line.chars.each_with_index.map do |char, y|
        map[x, y] = char if char != '.'
      end
    end
    map
  end

  def display
    (0..@height-1).each do |x|
      (0..@width-1).each do |y|
        elements = @hashmap[[x, y]]
        if elements
          print(elements.size > 1 ? elements.size : elements.first)
        else
          if @current_coords == [x, y]
            print('E')
          elsif @target_coords == [x, y]
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
    CACHE[@cost+1] ||= create_next_map
  end

  def create_next_map
    next_map_local = Map.new(@height, @width, cost: @cost+1)
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

  def next_paths
    # create next map
    next_map = self.next_map

    x, y = @current_coords
    [[-1, 0], [0, 0], [1, 0], [0, 1], [0, -1]].map do |dx, dy|
      next if x + dx < 0

      next_x, next_y = [x+dx, y+dy]
      next_map[next_x, next_y].nil? ? next_map.dup([next_x, next_y]) : nil
    end.compact
  end

  def distance_to_target
    x, y = @current_coords
    target_x, target_y = @target_coords
    (target_x - x).abs + (target_y - y).abs
  end
end

def solve_part1(file)
  initial_map = Map.from_file(file)


  pq = PriorityQueue.new
  pq.push(initial_map, 0)

  iter = 0
  while !pq.empty?
    current_map, _ = pq.pop

    puts "iter #{iter}, cost #{current_map.cost}, size #{current_map.size}, distance #{current_map.distance_to_target}" if iter % 50_000 == 0

    # check if we reached the target
    if current_map.current_coords == current_map.target_coords
      puts "Part1 (#{file}), found target with cost #{current_map.cost}"
      break
    end

    # add next paths to the queue
    current_map.next_paths.each do |next_map|
      pq.push(next_map, next_map.cost + next_map.distance_to_target)
    end
    iter += 1
  end
end

solve_part1('day24_sample.txt')
Map::CACHE.clear
solve_part1('day24.txt')