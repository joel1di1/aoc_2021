require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input3.txt'))

total_output_joltage = lines.map do |line|
  digits = line.chomp.chars.map(&:to_i)

  d_size = 2
  joltage = 0
  start_index = 0

  (d_size..0).each do |d_index|
    new_d = digits[start_index..-d_index].max
    joltage += new_d ** 10
    start_index = digits.find_index(new_d)
  end
end.sum

puts "part1 : #{total_output_joltage}"