require_relative '../../fwk'

def parse_input(path)
  File.readlines(path, chomp: true).map(&:split)
end


lines = parse_input(File.join(__dir__, 'input6.txt'))

col_size = lines.first.count

grand_total = (0...col_size).map do |col|
  col_numbers = lines[0...-1].map { |line| line[col].to_i }
  col_numbers.reduce(lines[-1][col])
end.sum 


puts "part 1 : #{grand_total}"
puts "part 2 : #{}"
