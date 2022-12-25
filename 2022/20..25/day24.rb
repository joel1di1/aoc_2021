require 'byebug'
require 'set'
require_relative '../../fwk'

class Map
  def initialize(height, width, current_coords)
    @hashmap = {}
    @width = width
    @height = height
    @current_coords = current_coords
    @target_coords = [@height-1, @width-2]
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
    map = Map.new(lines.size, lines.first.size, [0, 1])
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

  def next_paths
    paths = []
    x, y = @current_coords
    if x > 0 && self[x-1, y] != '#'
      paths << [x-1, y]
    end
    if x < @height-1 && self[x+1, y] != '#'
      paths << [x+1, y]
    end
    if y > 0 && self[x, y-1] != '#'
      paths << [x, y-1]
    end
    if y < @width-1 && self[x, y+1] != '#'
      paths << [x, y+1]
    end
    paths
  end
end

Map.from_file('day24_sample.txt').display