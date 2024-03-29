# frozen_string_literal: true

require_relative '../../fwk'

def shift(range)
  (range.min + @max..range.max + @max)
end

def select(range)
  ([range.min, 0].max..[range.max, 100].min)
end

def set(x_range:, y_range:, z_range:, value:)
  puts "set #{x_range} #{y_range} #{z_range} #{value}"
  x_range = shift(x_range)
  puts "x_range"
  y_range = shift(y_range)
  puts "y_range"
  z_range = shift(z_range)
  puts "z_range"

  x_range = select(x_range)
  puts "select x_range"
  y_range = select(y_range)
  puts "select x_range"
  z_range = select(z_range)
  puts "select x_range"

  x_range.each do |x| 
    y_range.each do |y|
      puts "x: #{x}, y: #{y}, z: #{z_range}"
      z_range.each { |z| @grid[x][y][z] = value }
    end
  end
end

def on(x_range:, y_range:, z_range:)
  set(x_range: x_range, y_range: y_range, z_range: z_range, value: 1)
end

def off(x_range:, y_range:, z_range:)
  set(x_range: x_range, y_range: y_range, z_range: z_range, value: 0)
end

def process(file)
  @max = 97736

  i = 0
  cmds = File.readlines(file).map do |l|
    i += 1
    puts "it : #{i}"
    l.strip.gsub('=', ':').gsub('x:', 'x_range:').gsub('y:', 'y_range:').gsub('z:', 'z_range:')
  end

  @grid = Array.new(2 * @max + 1) { Array.new(2 * @max + 1) { Array.new(2 * @max + 1) { 0 } } }

  cmds.each { |cmd| eval cmd }

  puts "total lit #{file}: #{@grid.flatten.sum}"
end

process('day22_small_sample.txt')
process('day22_sample.txt')
process('day22.txt')

