
require 'set'
require 'byebug'

map = File.readlines('day8.txt').map do |line|
  line.strip.chars.map(&:to_i)
end

visibles = {}

WIDTH = map.size

(0..WIDTH-1).each do |i|
  max_left = -1
  max_right = -1
  (0..WIDTH-1).each do |j|
    if map[i][j] > max_left
      max_left = map[i][j]
      visibles[[i, j]] = map[i][j]
    end
    if map[i][WIDTH-1-j] > max_right
      max_right = map[i][WIDTH-1-j]
      visibles[[i, WIDTH-1-j]] = map[i][WIDTH-1-j]
    end
  end
end

(0..WIDTH-1).each do |j|
  max_up = -1
  max_bottom = -1
  (0..WIDTH-1).each do |i|
    if map[i][j] > max_up
      max_up = map[i][j]
      visibles[[i, j]] = map[i][j]
    end
    if map[WIDTH-1-i][j] > max_bottom
      max_bottom = map[WIDTH-1-i][j]
      visibles[[WIDTH-1-i, j]] = map[WIDTH-1-i][j]
    end
  end
end

puts visibles.size

# new_map = Array.new(WIDTH) { Array.new }
# visibles.each do |k,v| 
#   new_map[k[0]][k[1]] = v 
# end

# new_map.each do |line|
#   line.each do |h|
#     putc(h.nil? ? ' ' : h.to_s)
#   end
#   putc "\n"
# end
@scenic_scores
def scenic_score(map, coords)
  i, j = coords
  height = map[i][j]

  top_score = 0
  i1 = i-1
  while i1 >= 0
    top_score += 1
    break if height <= map[i1][j]
    i1 -= 1    
  end

  bottom_score = 0
  i1 = i+1
  while i1 < WIDTH
    bottom_score += 1
    break if height <= map[i1][j]
    i1 += 1    
  end

  left_score = 0
  j1 = j-1
  while j1 >= 0
    left_score += 1
    break if height <= map[i][j1]
    j1 -= 1    
  end

  right_score = 0
  j1 = j+1
  while j1 < WIDTH
    right_score += 1
    break if height <= map[i][j1]
    j1 += 1    
  end

  top_score * bottom_score * left_score * right_score
end

max = (0..WIDTH-1).map { |i| (0..WIDTH-1).map{ |j| scenic_score(map, [i,j])}.max }.max

puts max