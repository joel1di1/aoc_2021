require 'byebug'
require 'set'
require_relative '../../fwk'

class Map
  def initialize
    @hashmap = {}
  end

  def [](x, y)
    @hashmap[[x, y]]
  end

  def []=(x, y, value)
    @hashmap[[x, y]] = value
  end

  def delete(x, y)
    @hashmap.delete([x, y])
  end

  def size
    @hashmap.size
  end

  def self.from_file(file)
    map = Map.new
    char_index = 65
    File.readlines(file).map(&:chomp).each_with_index.map do |line, x|
      line.chars.each_with_index.map do |char, y|
        # debugger if char == '#'
        if char == '#'
          map[x, y] = Cell.new(x, y, char_index.chr(Encoding::UTF_8), map) 
          char_index += 1
        end
      end
    end
    map
  end

  def display
    puts "============================================================================================================================\n"
    # find minmax of x and y
    min_x, max_x = @hashmap.keys.map(&:first).minmax
    min_y, max_y = @hashmap.keys.map(&:last).minmax

    (min_x..max_x).each do |x|
      (min_y..max_y).each do |y|
        cell = @hashmap[[x, y]]
        print( cell ? '#' :  '.')
        if cell
          raise "cell #{cell.char} is not at #{x}, #{y}" unless cell.x == x && cell.y == y
        end
      end
      puts
    end
  end

  def ground_tiles_count
    min_x, max_x = @hashmap.keys.map(&:first).minmax
    min_y, max_y = @hashmap.keys.map(&:last).minmax

    surface = (max_y - min_y + 1) * (max_x - min_x + 1)
    surface - @hashmap.size
  end


  def play_round
    proposition_map = {}
    @hashmap.values.each do |cell|
      proposition = cell.propose
      proposition_map[proposition] ||= []
      proposition_map[proposition] << cell
    end

    # select the ones with only one cell and move it
    proposition_map.map do |proposition, cells|
      if cells.size > 1
        cells.map(&:stay!)
        0
      else
        cells.map(&:move!).sum
      end
    end.sum
  end 

  def play
    iter = 0
    loop do
      iter += 1
      puts "round: #{iter}"
      break if play_round == 0
    end
    puts "\n\tPart2: #{iter}"
  end
end

class Cell
  attr_reader :x, :y, :char

  def initialize(x, y, char, map)
    @x = x
    @y = y
    @char = char
    @map = map
    @propositions = [:north, :south, :west, :east]
    @proc_per_direction = {
      north: -> (x, y) { [x-1, y] if [[x-1, y-1], [x-1, y], [x-1, y+1]].all? { |x, y| @map[x, y].nil? } },
      south: -> (x, y) { [x+1, y] if [[x+1, y-1], [x+1, y], [x+1, y+1]].all? { |x, y| @map[x, y].nil? } },
      west:  -> (x, y) { [x, y-1] if [[x-1, y-1], [x, y-1], [x+1, y-1]].all? { |x, y| @map[x, y].nil? } },
      east:  -> (x, y) { [x, y+1] if [[x-1, y+1], [x, y+1], [x+1, y+1]].all? { |x, y| @map[x, y].nil? } },
    }
  
  end

  def propose
    # if all neighbours are empty, don't move
    if [[@x-1, @y-1], [@x-1, @y], [@x-1, @y+1], [@x, @y-1], [@x, @y+1], [@x+1, @y-1], [@x+1, @y], [@x+1, @y+1]].all? { |x, y| @map[x, y].nil? }
      @last_proposition = [x, y] 
      return @last_proposition
    end

    @propositions.each do |direction|
      # puts "\t#{char} considering #{direction}"
      proposition = @proc_per_direction[direction].call(@x, @y)
      if proposition
        @last_proposition = proposition
        break
      end
    end
    @last_proposition ||= [x, y]
    # puts "\t#{char} proposing #{@last_proposition}"
    @last_proposition
  end

  def stay!
    # puts "\t#{char} staying"
    @propositions.rotate!
    0
  end

  def move!
    raise 'no last proposition' unless @last_proposition

    # puts "\t#{char} moving to #{@last_proposition}"
    @propositions.rotate!

    return 0 if [@x, @y] == @last_proposition

    @map.delete(@x, @y)
    @map[*@last_proposition] = self

    @x, @y = @last_proposition
    1
  end
end

map = Map.from_file('day23.txt')
puts "Initial size: #{map.size}"
# map.display
9.times do |i|
  map.play_round
  puts "Round #{i+1}"
  # map.display
end

puts "Part 1: #{map.ground_tiles_count}"
puts "Initial size: #{map.size}"

# part 2
map = Map.from_file('day23.txt')

map.play
