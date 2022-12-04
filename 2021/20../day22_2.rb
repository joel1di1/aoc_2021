# frozen_string_literal: true

require_relative '../../fwk'

def shift(range)
  (range.min + @max..range.max + @max)
end

def select(range)
  ([range.min, 0].max..[range.max, 100].min)
end

def set(x_range:, y_range:, z_range:, value:)
  x_range = shift(x_range)
  y_range = shift(y_range)
  z_range = shift(z_range)

  x_range = select(x_range)
  y_range = select(y_range)
  z_range = select(z_range)

  x_range.each { |x| y_range.each { |y| z_range.each { |z| @grid[x][y][z] = value } } }
end

def on(x_range:, y_range:, z_range:)
  set(x_range: x_range, y_range: y_range, z_range: z_range, value: 1)
end

def off(x_range:, y_range:, z_range:)
  set(x_range: x_range, y_range: y_range, z_range: z_range, value: 0)
end

def process(file)
  cmds = File.readlines(file).map do |l|
    l.strip.gsub('=', ':').gsub('x:', 'x_range:').gsub('y:', 'y_range:').gsub('z:', 'z_range:')
  end

  @ons_cubes = []

  cmds.each { |cmd| eval cmd }

  puts "total lit #{file}: #{@grid.flatten.sum}"
end

def read_max_integer_in_a_file(file)
  File.readlines(file).map { |l| l.scan(/\d+/).map(&:to_i) }.flatten.max
end

puts read_max_integer_in_a_file('day22.txt')

# process('day22_small_sample.txt')
# process('day22_sample.txt')
# process('day22.txt')

