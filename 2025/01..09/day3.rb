require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input3.txt'))

total_output_joltage = lines.map do |line|
  digits = line.chomp.chars.map(&:to_i)
  dizains = digits[0..-2].max
  units = digits[(digits.find_index(dizains) + 1)..].max
  (dizains * 10) + units
end.sum

puts "part1 : #{total_output_joltage}"