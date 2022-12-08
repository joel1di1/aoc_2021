
require 'set'
require 'byebug'

map = File.readlines('day8.txt').map do |line|
  line.strip.chars.map(&:to_i)
end

visibles = {}

width = map.size

(0..width-1).each do |i|
  max_left = -1
  max_right = -1
  (0..width-1).each do |j|
    if map[i][j] > max_left
      max_left = map[i][j]
      visibles[[i, j]] = map[i][j]
    end
    if map[i][width-1-j] > max_right
      max_right = map[i][width-1-j]
      visibles[[i, width-1-j]] = map[i][width-1-j]
    end
  end
end

(0..width-1).each do |j|
  max_up = -1
  max_bottom = -1
  (0..width-1).each do |i|
    if map[i][j] > max_up
      max_up = map[i][j]
      visibles[[i, j]] = map[i][j]
    end
    if map[width-1-i][j] > max_bottom
      max_bottom = map[width-1-i][j]
      visibles[[width-1-i, j]] = map[width-1-i][j]
    end
  end
end

puts visibles.size
# puts visibles.inspect

new_map = Array.new(width) { Array.new }
visibles.each do |k,v| 
  new_map[k[0]][k[1]] = v 
end

new_map.each do |line|
  line.each do |h|
    putc(h.nil? ? ' ' : h.to_s)
  end
  putc "\n"
end


# pp new_map
# pp new_map.flatten.compact.size
