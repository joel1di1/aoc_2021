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

def move_sand(positions, x, y)
  # if we are at the bottom, we stop
  return :abyss if y == MAX_Y

  # if we are on a rock or sand
  if positions[[x, y+1]]
    # we try to move left
    if positions[[x-1, y+1]].nil?
      move_sand(positions, x-1, y+1)
    # if we can't move left, we try to move right
    elsif positions[[x+1, y+1]].nil?
      move_sand(positions, x+1, y+1)
    else
      # we mark the current position as sand
      positions[[x, y]] = :sand
      return :sand
    end
  else
    # we move down
    move_sand(positions, x, y+1)
  end
end

def produce_sand(positions)
  move_sand(positions, 500, 0)
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
while produce_sand(positions) != :abyss
  sand_count += 1
end

puts "Sand count: #{sand_count}"
