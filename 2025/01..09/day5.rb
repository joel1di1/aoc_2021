require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input5.txt'))

ranges = []

line_index = 0
loop do 
  line = lines[line_index].chomp
  line_index += 1
  break if line.empty?

  left, right = line.split('-').map(&:to_i)
  ranges << (left..right)
end

ingredient_ids = lines[line_index..].map(&:to_i)

fresh_count = ingredient_ids.select { |id| ranges.any? { |range| range.include?(id) } }.count

puts "part 1 : #{fresh_count}"
