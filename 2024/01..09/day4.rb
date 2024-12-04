require 'byebug'

chars = File.readlines(File.join(__dir__, 'input4.txt')).map(&:strip).map(&:chars)

# use regexep to count occurence of 'xmas' in each line
MASKS_PART1 = [
  {[0,0] => 'X', [0,1] => 'M', [0,2] => 'A', [0,3] => 'S'},
  {[0,0] => 'S', [0,1] => 'A', [0,2] => 'M', [0,3] => 'X'},
  {[0,0] => 'X', [1,0] => 'M', [2,0] => 'A', [3,0] => 'S'},
  {[0,0] => 'S', [1,0] => 'A', [2,0] => 'M', [3,0] => 'X'},
  {[0,0] => 'X', [1,1] => 'M', [2,2] => 'A', [3,3] => 'S'},
  {[0,0] => 'S', [1,1] => 'A', [2,2] => 'M', [3,3] => 'X'},
  {[0,3] => 'X', [1,2] => 'M', [2,1] => 'A', [3,0] => 'S'},
  {[0,3] => 'S', [1,2] => 'A', [2,1] => 'M', [3,0] => 'X'},
].freeze

MASKS_PART2 = [
  {[0,0] => 'M', [0,2] => 'S', [1,1] => 'A', [2,0] => 'M', [2,2] => 'S'},
  {[0,0] => 'M', [0,2] => 'M', [1,1] => 'A', [2,0] => 'S', [2,2] => 'S'},
  {[0,0] => 'S', [0,2] => 'M', [1,1] => 'A', [2,0] => 'S', [2,2] => 'M'},
  {[0,0] => 'S', [0,2] => 'S', [1,1] => 'A', [2,0] => 'M', [2,2] => 'M'},

].freeze

def mask?(chars, i, j, mask)
  mask.entries.all? do |coords, value|
    i+coords[0] < chars.size && j+coords[1] < chars[i].size && chars[i+coords[0]][j+coords[1]] == value
  end
end

def count_xmas(chars, masks)
  (0..chars.size-1).map do |i|
    (0..chars[i].size-1).map do |j|
      masks.map do |mask|
        mask?(chars, i, j, mask) ? 1 : 0
      end.sum
    end.sum
  end.sum
end



puts "part1: #{count_xmas(chars, MASKS_PART1)}"
puts "part2: #{count_xmas(chars, MASKS_PART2)}"
