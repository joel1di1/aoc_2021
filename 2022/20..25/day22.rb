require 'byebug'

class Person
  DIRECTIONS = ['>', 'v', '<', '^']
  DIRECTIONS_OFFSETS = {'>' => [1, 0], '^' => [0, -1], '<' => [-1, 0], 'v' => [0, 1]}

  attr_reader :current_tile, :direction

  def initialize(current_tile, direction)
    @direction = direction
    @current_tile = current_tile
  end

  def on?(tile)
    current_tile == tile
  end

  def turn_left
    @direction = DIRECTIONS[(DIRECTIONS.index(direction) - 1) % DIRECTIONS.size]
  end

  def turn_right
    @direction = DIRECTIONS[(DIRECTIONS.index(direction) + 1) % DIRECTIONS.size]
  end

  def move_forward(steps)
    steps.times do
      move!
    end
  end

  def move!
    next_tile = case direction
      when '^'
        @current_tile.top
      when 'v'
        @current_tile.bottom
      when '>'
        @current_tile.right
      when '<'
        @current_tile.left
      end

    return if next_tile.wall?

    if next_tile.is_a?(SideTransition)
      @direction = next_tile.direction
      next_tile = next_tile.target
    end

    @current_tile = next_tile
  end

  def inspect
    to_s
  end
end

class Tile
  attr_accessor :left, :right, :top, :bottom, :x, :y, :value

  def initialize(x, y, value)
    @x = x
    @y = y
    @left = nil
    @right = nil
    @top = nil
    @bottom = nil
    @value = value
  end

  def wall?
    @value == '#'
  end

  def to_s
    value.to_s
  end

  def coordinates
    [x, y]
  end
end

class Map
  def initialize(grid)
    @grid = grid
  end

  def get(x, y)
    @grid[x][y]
  end

  def display(person)
    puts "\n============================================================================================================================\n"
    @grid.each do |row|
      row.each do |cell|
        if person && person.on?(cell)
          print person.direction
        else
          print(cell&.value || ' ')
        end
      end
      puts
    end
  end
end

class SideTransition
  attr_reader :target, :direction

  def initialize(target, direction)
    @target = target
    @direction = direction
  end

  def wall?
    target.wall?
  end
end

def read_input(file_path)
  lines = File.readlines(file_path).map(&:chomp)

  instruction_line = lines.last
  lines = lines[0..-3]

  width = lines.map(&:size).max
  grid = Array.new(lines.size) { Array.new(width) }

  top_tile_per_column = Array.new(width)

  # each line is a row
  top_tile_per_column = []
  left_tile_per_row = []
  right_tile_per_row = []
  bottom_tile_per_column = []

  chars_grid = lines.map(&:chars)
  chars_grid.each_with_index do |line, row_index|
    line.each_with_index do |char, cell_index|
      # create a tile for each character not a space
      next if char == ' '

      tile = Tile.new(row_index, cell_index, char)
      grid[row_index][cell_index] = tile

      upper_tile = grid.dig(row_index-1, cell_index)
      if upper_tile
        tile.top = upper_tile
        upper_tile.bottom = tile
      end

      left_tile = grid.dig(row_index, cell_index-1)
      if left_tile
        tile.left = left_tile
        left_tile.right = tile
      end

      bottom_char = chars_grid.dig(row_index+1, cell_index)
      if bottom_char.nil? || bottom_char == ' '
        bottom_tile = top_tile_per_column[cell_index]
        tile.bottom = bottom_tile
        bottom_tile.top = tile
      end

      right_char = chars_grid.dig(row_index, cell_index+1)
      if right_char.nil? || right_char == ' '
        right_tile = left_tile_per_row[row_index]
        tile.right = right_tile
        right_tile.left = tile
      end

      top_tile_per_column[cell_index] ||= tile
      left_tile_per_row[row_index] ||= tile
      right_tile_per_row[row_index] = tile
      bottom_tile_per_column[cell_index] = tile
    end
  end

  [grid, instruction_line]
end

grid, instructions_str = read_input('day22.txt')

map = Map.new(grid)

# map.display(nil)

# You begin the path in the leftmost open tile
y = 0
tmp = map.get(0,y)
while tmp == nil
  y += 1
  tmp = map.get(0,y)
end

person = Person.new(tmp, '>')

while instructions_str.size > 0
  instr, instructions_str = instructions_str.match(/^(\d+|[RL])(.*)/).captures

  case instr
  when 'L'
    person.turn_left
  when 'R'
    person.turn_right
  else
    person.move_forward(instr.to_i)
  end

  # puts "instruction: #{instr}"
  # map.display(person)
end


x, y = person.current_tile.coordinates
password = (x+1) * 1000 + (y+1) * 4 + Person::DIRECTIONS.index(person.direction)

puts "Part1: final position: #{person.current_tile.coordinates}, password: #{password}"


def read_input_3d(file_path)
  lines = File.readlines(file_path).map(&:chomp)

  instruction_line = lines.last

  lines = lines[0..-3]

  width = lines.map(&:size).max
  grid = Array.new(lines.size) { Array.new(width) }

  top_tile_per_column = Array.new(width)

  chars_grid = lines.map(&:chars)
  chars_grid.each_with_index do |line, row_index|
    line.each_with_index do |char, cell_index|
      # create a tile for each character not a space
      next if char == ' '

      tile = Tile.new(row_index, cell_index, char)
      grid[row_index][cell_index] = tile

      upper_tile = grid.dig(row_index-1, cell_index)
      if upper_tile
        tile.top = upper_tile
        upper_tile.bottom = tile
      end

      left_tile = grid.dig(row_index, cell_index-1)
      if left_tile
        tile.left = left_tile
        left_tile.right = tile
      end
    end
  end

  # link side of the cubes
  # (0, 50->99) <=> (150->199, 0)
  #   (0, 50).top => (150, 0), direction up becomes right
  #   (0, 99).top => (190, 0), direction up becomes right
  #   (150, 0).left => (0, 50), direction left becomes down
  #   (199, 0).left => (0, 99), direction left becomes down
  (0..49).each do |i|
    tile = grid[0][i + 50]
    transition = SideTransition.new(grid[150 + (i)][0], '>')
    tile.top = transition

    tile = grid[i + 150][0]
    transition = SideTransition.new(grid[0][i + 50], 'v')
    tile.left = transition
  end

  # (0, 100->149) <=> (199, 0->49)
  (0..49).each do |i|
    tile = grid.dig(0, i + 100)
    transition = SideTransition.new(grid.dig(199, i), '^')
    tile.top = transition

    tile = grid.dig(199, i)
    transition = SideTransition.new(grid.dig(0, i+100), 'v')
    tile.bottom = transition
  end


  # (49, 100->149) <=> (50->99, 99)
  (0..49).each do |i|
    tile = grid.dig(49, i + 100)
    transition = SideTransition.new(grid.dig(i +50, 99), '<')
    tile.bottom = transition

    tile = grid.dig(i +50, 99)
    transition = SideTransition.new(grid.dig(49, i + 100), '^')
    tile.right = transition
  end


  # (100->149, 99) <=> (0->49, 149)
  (0..49).each do |i|
    tile = grid.dig(i + 100, 99)
    transition = SideTransition.new(grid.dig(49 - i, 149), '<')
    tile.right = transition
    debugger if transition.target.nil?

    tile = grid.dig(i, 149)
    transition = SideTransition.new(grid.dig(149 - i, 99), '<')
    debugger if transition.target.nil?
    tile.right = transition
  end
  
  # (100->149, 0) <=> (0->49, 50)
  (0..49).each do |i|
    tile = grid.dig(i + 100, 0)
    transition = SideTransition.new(grid.dig(49 - i, 50), '>')
    tile.left = transition

    tile = grid.dig(i, 50)
    transition = SideTransition.new(grid.dig(149 - i, 0), '>')
    tile.left = transition
  end

  # (150->199, 49) <=> (149, 50->99)
  (0..49).each do |i|
    tile = grid.dig(i + 150, 49)
    transition = SideTransition.new(grid.dig(149, i + 50), '^')
    tile.right = transition

    tile = grid.dig(149, i + 50)
    transition = SideTransition.new(grid.dig(i + 150, 49), '<')
    tile.bottom = transition
  end

  # (50->99, 50) <=> (100, 0->49)
  (0..49).each do |i|
    tile = grid.dig(i + 50, 50)
    transition = SideTransition.new(grid.dig(100, i), 'v')
    tile.left = transition

    tile = grid.dig(100, i)
    transition = SideTransition.new(grid.dig(i + 50, 50), '>')
    tile.top = transition
  end

  [grid, instruction_line]
end

grid, instructions_str = read_input_3d('day22.txt')

map = Map.new(grid)

# person = Person.new(map.get(100, 48), '^')
# map.display(person)
# person.move_forward(2)
# map.display(person)

# person.turn_left
# person.turn_left

# person.move_forward(3)
# map.display(person)


y = 0
tmp = map.get(0,y)
while tmp == nil
  y += 1
  tmp = map.get(0,y)
end

person = Person.new(tmp, '>')

while instructions_str.size > 0
  instr, instructions_str = instructions_str.match(/^(\d+|[RL])(.*)/).captures

  case instr
  when 'L'
    person.turn_left
  when 'R'
    person.turn_right
  else
    person.move_forward(instr.to_i)
  end

  # puts "instruction: #{instr}"
  # map.display(person)
end


x, y = person.current_tile.coordinates
password = (x+1) * 1000 + (y+1) * 4 + Person::DIRECTIONS.index(person.direction)

puts "Part1: final position: #{person.current_tile.coordinates}, password: #{password}"
