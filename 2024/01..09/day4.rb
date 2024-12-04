require 'byebug'

lines = File.readlines(File.join(__dir__, 'input4.txt')).map(&:strip)

# use regexep to count occurence of 'xmas' in each line
REGEXPS = [/XMAS/, /SAMX/].freeze

def count_xmas(lines)
  lines.map do |line|
    REGEXPS.map do |regexp|
      line.scan(regexp).count
    end.sum
  end.sum
end

horizontal_nb = count_xmas(lines)

# transpose the array to count occurence of 'xmas' in each column
vertical_nb = count_xmas(lines.map(&:chars).transpose.map(&:join))

# create a new array with all diagonal lines
diagonal_lines_1 = []
diagonal_lines_2 = []
(0..lines.size + lines[0].size - 2).each do |i|
  diagonal_lines_1 << (0..i).map do |j|
    lines[j][i - j] if j < lines.size && i - j < lines[0].size
  end.compact.join
end

(0..lines.size + lines[0].size - 2).each do |i|
  diagonal_lines_2 << (0..i).map do |j|
    lines[j][lines[0].size - i + j] if j < lines.size && lines[0].size - i + j >= 0
  end.compact.join
end

diagonal_nb_1 = count_xmas(diagonal_lines_1)
diagonal_nb_2 = count_xmas(diagonal_lines_2)

sum = horizontal_nb + vertical_nb + diagonal_nb_1 + diagonal_nb_2

puts "part1: #{sum}"
