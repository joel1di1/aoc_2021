require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input4.txt'))

MAX_X = lines.first.size
MAX_Y = lines.size

GRID = {} # rubocop:disable Style/MutableConstant
lines.each_with_index do |line, x|
  line.chars.each_with_index do |c, y|
    GRID[[x, y]] = c
  end
end

def neighbors(x, y)
  [[x-1, y-1], [x, y-1], [x+1, y-1],
   [x-1, y], [x+1, y],
   [x-1, y+1], [x, y+1], [x+1, y+1]].select { |a, b| a >= 0 && a < MAX_X && b >= 0 && b < MAX_Y }
end

def liftable?(x, y)
  return false if GRID[[x, y]] != '@'
  
  neighbors(x, y).select { |neigbor| GRID[neigbor] == '@' }.count < 4
end

liftable = 0
(0...MAX_X).each do |x|
  (0...MAX_Y).each do |y|
    liftable += 1 if liftable?(x, y)
  end
end

puts "part 1 : #{liftable}"


initial_roll_count = GRID.values.select { |p| p == '@' }.count
to_lift = [[-1, -1]]

until to_lift.empty? 
  to_lift.each { |roll| GRID.delete(roll) }
  to_lift = []
  
  (0...MAX_X).each do |x|
    (0...MAX_Y).each do |y|
      to_lift << [x, y] if liftable?(x, y)
    end
  end

end


puts "part 2 : #{initial_roll_count - GRID.values.select { |p| p == '@' }.count}"
