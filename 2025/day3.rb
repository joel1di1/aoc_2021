require_relative '../fwk'

LINES = File.readlines(File.join(__dir__, 'input3.txt'))

def find_joltage(d_size)
  LINES.map do |line|
    digits = line.chomp.chars.map(&:to_i)

    start_index = 0

    (1..d_size).to_a.reverse.map do |d_index|
      new_d = digits[start_index..-d_index].max
      start_index = digits[start_index..].find_index(new_d) + start_index + 1
      new_d * (10 ** (d_index-1))
    end.sum
  end.sum
end


puts "part 1 : #{find_joltage(2)}"
puts "part 2 : #{find_joltage(12)}"