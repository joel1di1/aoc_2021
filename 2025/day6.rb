require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input6.txt'), chomp: true).map(&:split)

col_size = lines.first.count

grand_total = (0...col_size).map do |col|
  col_numbers = lines[0...-1].map { |line| line[col].to_i }
  col_numbers.reduce(lines[-1][col])
end.sum 

puts "part 1 : #{grand_total}"

lines = File.readlines(File.join(__dir__, 'input6.txt'), chomp: false)
op_line = lines[-1]
num_lines = lines[0...-1]

grand_total = 0 

start_index = 0
while start_index < op_line.size
  op = op_line[start_index]
  num_size = op_line[(start_index + 1)..].index(/[+*]|$/)
  numbers_s = num_lines.each_with_object(Array.new(num_size) { '' }) do |line, numbers_s|
    (0...num_size).each do |col|
      numbers_s[col] += line[start_index + col] || ' '
    end
  end

  grand_total += numbers_s.map(&:to_i).reduce(op)
  start_index += num_size + 1
end

puts "part 2 : #{grand_total}"
