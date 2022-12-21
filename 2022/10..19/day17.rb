require 'byebug'
require 'set'

MOVES = {
  north: { coords_left: [0,-1], coords_right: [0,1], coords_front: [-1,0],  coords_back: [1,0], left: :west, right: :east, front: :north, back: :south },
  south: { coords_left: [0,1], coords_right: [0,-1], coords_front: [1,0],  coords_back: [-1,0], left: :east, right: :west, front: :south, back: :north },
  east: { coords_left: [-1,0], coords_right: [1,0], coords_front: [0,1],  coords_back: [0,-1], left: :north, right: :south, front: :east, back: :west },
  west: { coords_left: [1,0], coords_right: [-1,0], coords_front: [0,-1],  coords_back: [0,1], left: :south, right: :north, front: :west, back: :east}
}


class Shape
  shape_minus = {[0,0].freeze => '#', [0,1].freeze => '#', [0,2].freeze => '#', [0,3].freeze => '#'}.freeze
  shape_plus  = {[0,1].freeze => '#', [1,0].freeze => '#', [1,1].freeze => '#', [1,2].freeze => '#', [2,1].freeze => '#'}.freeze
  shape_L = {[0,2].freeze => '#', [1,2].freeze => '#', [2,0].freeze => '#', [2,1].freeze => '#', [2,2].freeze => '#'}.freeze
  shape_I = {[0,0].freeze => '#', [1,0].freeze => '#', [2,0].freeze => '#', [3,0].freeze => '#'}.freeze
  shape_square = {[0,0].freeze => '#', [0,1].freeze => '#', [1,0].freeze => '#', [1,1].freeze => '#'}.freeze

  ORDERED_SHAPES = [shape_minus, shape_plus, shape_L, shape_I, shape_square].freeze

  attr_reader :positions

  @@index_shape = 0

  def self.index_shape
    @@index_shape
  end

  def self.reset!
    @@index_shape = 0
  end

  def self.next
    new_shape = ORDERED_SHAPES[@@index_shape % ORDERED_SHAPES.size].keys.map(&:dup)
    # puts "new shape: #{new_shape}"
    @@index_shape += 1
    self.new(new_shape)
  end
  
  def initialize(positions)
    @positions = positions
  end

  def move(shift_x, shift_y)
    @positions.map! {|x,y| [x+shift_x, y+shift_y]}
  end

  def push_left(shift=1)
    move(0, -shift)
  end

  def push_right(shift=1)
    move(0, shift)
  end

  def push_down(shift=1)
    move(shift, 0)
  end

  def next_positions(shift_x, shift_y)
    @positions.map {|x,y| [x+shift_x, y+shift_y]}
  end

  def to_s
    positions.map(&:to_s).join(' ')
  end

  def height
    min_x, max_x = positions.map(&:first).minmax
    max_x - min_x
  end
end

class Board
  WIDTH = 7

  def initialize
    @board = {}
    (0..WIDTH-1).each do |y|
      @board[[0,y]] = '-'
    end
    @current_shape = nil
  end

  def [](x,y)
    return '|' if y < 0 || y >= WIDTH
    @board[[x,y]]
  end

  def display
    min_x, max_x = @board.keys.map(&:first).minmax
    min_y, max_y = @board.keys.map(&:last).minmax

    min_x -= 4

    puts
    ((min_x-3)..max_x).each do |x|
        # print line number
        print(x.to_s.rjust(5))
        print(" ")
      (min_y..max_y).each do |y|
        print self[x,y] || (@current_shape&.positions&.include?([x,y]) ? '@' : nil) || '.'
      end
      puts
    end
  end

  def add_new_shape
    @current_shape = Shape.next
    # move current_sape 3 spaces on top of the highest block
    @current_shape.push_down(top_x - 4 - @current_shape.height)
    # move current_sape 2 spaces from the left
    @current_shape.push_right(2)
  end

  def top_x
    @board.keys.map(&:first).min
  end

  def apply_instruction(instruction)
    shift_x = 0
    shift_y = 0
    if instruction == '<'
      shift_y = -1
    else
      shift_y = 1
    end
    # check if we can move
    if @current_shape.next_positions(shift_x, shift_y).all? { |x,y|  self[x,y].nil? && (y >= 0 && y < WIDTH) }
      @current_shape.move(shift_x, shift_y) 
    end
  end

  def apply_gravity(clean:)
    # check if we can move
    if @current_shape.next_positions(1, 0).all? {|x,y| self[x,y].nil?}
      @current_shape.push_down
    else
      freeze!(clean:)
    end
  end

  def freeze!(clean:)
    @current_shape.positions.each do |x,y|
      @board[[x,y]] = '#'
    end
    @current_shape = nil

    remove_unused_points! if clean
  end

  def remove_unused_points!
    display if Shape.index_shape == 511
    points_to_keep = Set.new

    debugger if Shape.index_shape == 511
    # get the highest point on column WIDTH-1
    target_y = WIDTH-1
    target_x = @board.keys.select{|x, y| y == target_y}.map(&:first).min
    
    # get the highest point on column 0
    current_x = @board.keys.select{|x, y| y == 0}.map(&:first).min
    current_y = 0
    
    points_to_keep << [current_x, current_y]

    directions = [:north, :east, :south, :west]
    current_direction = 0
    
    loop do
      if current_x == target_x && current_y == target_y
        # debugger
        break if @board[[target_x, target_y - 1]].nil?
        break if points_to_keep.include?([target_x, target_y - 1])
      end

      # if block in front of us, move to it
      moved = false
      until moved
        if @board[[current_x + MOVES[directions[current_direction]][:coords_front][0], current_y + MOVES[directions[current_direction]][:coords_front][1]]]
          points_to_keep << [current_x, current_y]
          current_x, current_y = [current_x, current_y].zip(MOVES[directions[current_direction]][:coords_front]).map(&:sum)
          puts "move to #{current_x}, #{current_y}"
          current_direction -= 1 # turn left
          moved = true
        else
          puts 'turn right'
          current_direction += 1 # turn right
          current_direction = current_direction % directions.size
        end
      end

      if current_y == target_y && current_x == target_x && Shape.index_shape == 511
        debugger 
        puts 'coucou'
      end
      # debugger 
    end

    debugger
    puts "points to keep : #{points_to_keep.size}"
    @board = @board.select{|k,v| points_to_keep.include?(k)}
  end

  def freezed?
    @current_shape.nil?
  end
end

def find_max_x(nb_shapes, clean: false)
  instructions = File.readlines('day17.txt').first.strip.chars

  Shape.reset!
  board = Board.new
  turn = 0
  loop do 
    if board.freezed?
      # check if max number of shapes
      break if Shape.index_shape >= nb_shapes
      puts "================= new shape #{Shape.index_shape} ==============="
      board.add_new_shape 
      # board.display
    end
  
    instruction = instructions[turn%instructions.size]
    puts "\n================= turn #{turn+1} : #{instruction} ===============" if turn % 10_000 == 0

    board.apply_instruction(instruction)
    board.display if Shape.index_shape == 511
  
    board.apply_gravity(clean:)
    board.display if Shape.index_shape == 511
  
    turn += 1
  end
  
  board.display
  -board.top_x
end

puts "================= clean false ==============="
part1= find_max_x(2022, clean: false)
puts "================= clean true ==============="
part1_clean= find_max_x(2022, clean: true)
puts "part 1: #{part1} expected 3117"
puts "part 1 cleaned : #{part1_clean} expected 3117"

# puts "-- ERROR --" if part1 != 3117

# part2= find_max_x(1000000000000)
# puts "part 2: #{part2}"



# ##
# # 10091 instructions
# # 