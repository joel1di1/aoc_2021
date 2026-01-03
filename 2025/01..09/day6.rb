require_relative '../../fwk'

lines = File.readlines(path, chomp: true).map(&:split)

col_size = lines.first.count

grand_total = (0...col_size).map do |col|
  col_numbers = lines[0...-1].map { |line| line[col].to_i }
  col_numbers.reduce(lines[-1][col])
end.sum 

puts "part 1 : #{grand_total}"

lines = File.readlines(path, chomp: true)
op_line = lines[-1]
num_lines = lines[0...-1]

grand_total = 0 

start_index = 0
op = op_line.first
num_size = op_line[1..].index(/[+*]/)
numbers_s = num_lines.each_with_object(Array.new(num_size) { '' }) do |numbers_s, line|
  (0...num_size).each do |col|
    numbers_s[col] += line[col]  
  end
end

puts numbers_s

puts "part 2 : #{grand_total}"
