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

    @current_tile = next_tile unless next_tile.wall?
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
    puts "==============================="
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

puts "Final position: #{person.current_tile.coordinates}, password: #{password}"
