require 'byebug'

def extract_rocks(line, rock_positions = {})
  return rock_positions if line.nil? || line.empty?
  
  if line =~ /^(\d+),(\d+) -> (\d+),(\d+)/
    x1, y1, x2, y2 = $1.to_i, $2.to_i, $3.to_i, $4.to_i
    # mark each position between x1,y1 and x2,y2 as a rock

    # horizontal line
    if y1 == y2
      sorted_x = [x1, x2].sort
      (sorted_x[0]..sorted_x[1]).each do |x|
        rock_positions[[x, y1]] = :rock
      end
    # vertical line
    elsif x1 == x2
      sorted_y = [y1, y2].sort
      (sorted_y[0]..sorted_y[1]).each do |y|
        rock_positions[[x1, y]] = :rock
      end
    end

    extract_rocks(line.match(/^\d+,\d+ -> (.*)/)[1], rock_positions)
  end
end

# draw map
def draw_map(positions)
  puts ""
  min_x, max_x = positions.keys.map(&:first).minmax
  min_y, max_y = positions.keys.map(&:last).minmax

  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      case positions[[x, y]]
      when :rock
        print '#'
      when :sand
        print 'o'
      else
        print '.'
      end
    end
    puts
  end
end


def occupied?(positions, x, y, bottom)
  (bottom && y == MAX_Y+2) || positions[[x, y]]
end

def free?(positions, x, y, bottom)
  !occupied?(positions, x, y, bottom)
end

def move_sand(positions, x, y, bottom)
  # if we are at the bottom, we stop
  return :abyss if !bottom && y == MAX_Y
  return :top if occupied?(positions, 500, 0, bottom)

  if occupied?(positions, x, y+1, bottom)
    # we try to move left
    if free?(positions, x-1, y+1, bottom)
      move_sand(positions, x-1, y+1, bottom)
    # if we can't move left, we try to move right
    elsif free?(positions, x+1, y+1, bottom)
      move_sand(positions, x+1, y+1, bottom)
    else
      # we mark the current position as sand
      positions[[x, y]] = :sand  
      return :sand
    end
  else
    # we move down
    move_sand(positions, x, y+1, bottom)
  end
end

def produce_sand(positions, bottom)
  move_sand(positions, 500, 0, bottom)
end

# main
positions = {}

# draw lines
# line exemple: 511,101 -> 511,103 -> 504,103
File.readlines('day14.txt').each do |line|
  line = line.strip
  # get the rock positions
  extract_rocks(line, positions)  
end

# min maxs
MIN_X, MAX_X = positions.keys.map(&:first).minmax
MIN_Y, MAX_Y = positions.keys.map(&:last).minmax

puts "MIN_X: #{MIN_X}, MAX_X: #{MAX_X}, MIN_Y: #{MIN_Y}, MAX_Y: #{MAX_Y}"

# draw the map
draw_map(positions)

# produce sand until it returns :abyss
# count the number of sand
sand_count = 0
while produce_sand(positions, false) != :abyss
  sand_count += 1
end

puts "Part1: #{sand_count}"

draw_map(positions)



# remove the sand
positions.delete_if { |_, v| v == :sand }

sand_count = 0
while produce_sand(positions, true) != :top
  sand_count += 1
end
puts "Part2: #{sand_count}"

draw_map(positions)







