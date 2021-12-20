# frozen_string_literal: true

require_relative '../../fwk'

COORDS = (-1..1).map { |i| (-1..1).map { |j| [i, j] } }.reduce([]) do |arr, l|
  arr += l
end

def get_input(input, mask_output_i, mask_output_j, default_value)
  mask_input_i = mask_output_i - 1
  mask_input_j = mask_output_j - 1
  return default_value if [mask_input_i, mask_input_j].any? { |c| c < 0 || c >= input.size }

  input[mask_input_i][mask_input_j]
end

def input_values(input, output_i, output_j, default_value)
  COORDS.map do |plus_i, plus_j|
    get_input(input, output_i + plus_i, output_j + plus_j, default_value)
  end.join
end

def enhance(input, transfo_map, default)
  output = Array.new(input.size + 2) { Array.new(input.size + 2) { 0 } }

  (0..output.size - 1).each do |output_i|
    (0..output.size - 1).each do |output_j|
      index = input_values(input, output_i, output_j, default).to_i(2)
      new_val = transfo_map[index]
      output[output_i][output_j] = new_val
    end
  end
  output
end

def display(grid)
  puts(grid.map { |row| row.map { |c| c.zero? ? '.' : '#' }.join }.join("\n"))
end

def process(file, times = 1, swap = false)
  lines = File.readlines(file).map(&:strip)

  transfo_map = lines.first.chars.map { |c| c == '#' ? 1 : 0 }

  input = lines[2..].map { |l| l.chars.map { |c| c == '#' ? 1 : 0 } }
  display(input)

  output = nil
  times.times do |iter|
    output = enhance(input, transfo_map, swap ? iter % 2 : 0)
    input = output
    puts "iter: #{iter}"
  end
  puts "lits: #{output.flatten.sum}"
end

def tests
  assert_eq '000000000', input_values([[0, 0, 0], [0, 0, 0], [0, 0, 0]], 0, 0, 0)
  assert_eq '000000000', input_values([[0, 0, 0], [0, 0, 0], [0, 0, 1]], 1, 1, 0)
  assert_eq '000000001', input_values([[0, 0, 0], [0, 0, 0], [0, 0, 1]], 2, 2, 0)
  assert_eq '000010001', input_values([[1, 0, 0], [0, 1, 0], [0, 0, 1]], 1, 1, 0)
  assert_eq '100010001', input_values([[1, 0, 0], [0, 1, 0], [0, 0, 1]], 2, 2, 0)
  assert_eq '111111110', input_values([[0, 0, 0], [0, 0, 0], [0, 0, 0]], 0, 0, 1)

  puts "TESTS OK"
end

tests

process('day20_sample.txt', 50)
process('day20.txt', 50, true)