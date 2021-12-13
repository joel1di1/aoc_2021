# frozen_string_literal: true

require_relative '../../fwk'

def sym(number, axe_index)
  number > axe_index  ? number - 2 * (number - axe_index) : number
end

def process(file)
  lines = File.readlines(file).map(&:strip)

  all_dots = lines.select { |l| l[/^\d+,\d/] }.map do |line|
    line.scan(/^(\d+),(\d+)/)[0].map(&:to_i)
  end
  folds =
    lines.select { |l| l[/fold along (x|y)=(\d+)/] }.map do |line|
      scan = line.scan(/fold along (x|y)=(\d+)/)
      { axe: scan[0][0], index: scan[0][1].to_i }
    end

  folds.each do |fold|
    all_dots.map! do |dot|
      if fold[:axe] == 'x'
        [sym(dot[0], fold[:index]), dot[1]]
      else
        [dot[0], sym(dot[1], fold[:index])]
      end
    end
    all_dots.uniq!

    puts "after fold #{fold}, count: #{all_dots.count}"
  end
  x_size = all_dots.map { |d| d[0] }.max
  y_size = all_dots.map { |d| d[1] }.max
  grid = Array.new(y_size+1) { Array.new(x_size+1, ' ') }

  all_dots.each { |x, y| grid[y][x] = '#' }

  puts ''
  puts grid.map{|line| line.join}.join("\n")
end

# process('day13_sample.txt')
process('day13.txt')
#
#
#
#
# 895 x 1308
#
# 655