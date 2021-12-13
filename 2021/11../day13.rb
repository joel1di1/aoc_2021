# frozen_string_literal: true

require_relative '../../fwk'

class Grid
  def initialize
    @matrix = []
  end

  def mark(x, y)
    set(x, y, 1)
  end

  def set(x, y, value)
    @matrix[y] ||= []
    @matrix[y][x] = value
  end

  def fill(x, y)
    set(x, y, 0) unless get(x, y)
  end

  def get(x, y)
    @matrix[y] ||= []
    @matrix[y][x] ||= 0
  end

  def fill_empty
    y_size = @matrix.size
    x_size = @matrix.map { |line| line ? line.size : 0 }.max
    (0..x_size - 1).each do |x|
      (0..y_size - 1).each do |y|
        fill(x, y)
      end
    end
  end

  def y_size
    @y_size ||= @matrix.size
  end

  def x_size
    @x_size ||= @matrix.map { |line| line ? line.size : 0 }.max
  end

  def display(msg)
    puts "\n#{msg}\n--------------------------"

    puts((0..y_size - 1).map do |y|
      (0..x_size - 1).map do |x|
        get(x, y)
      end.join
    end.join("\n"))
  end

  def apply_fold(fold)
    sum = 0
    if fold[:axe] == 'y'
      raise if y_size / 2 + 1 != fold[:index]
      new_matrix = Array.new(fold[:index]) { Array.new(x_size, 0) }
      (0..new_matrix.size - 1).each do |y|
        (0..x_size - 1).each do |x|
          sum += 1 if get(x, y) && get(x, y_size - 1 - y)
          new_matrix[y][x] = get(x, y) | get(x, y_size - 1 - y)
        end
      end
    else
      raise if x_size / 2 + 1 != fold[:index]
      new_matrix = Array.new(y_size) { Array.new(fold[:index], 0) }
      (0..new_matrix.size - 1).each do |y|
        (0..new_matrix.first.size - 1).each do |x|
          sum += 1 if get(x, y) && get(x_size - 1 - x, y)
          new_matrix[y][x] = get(x, y) | get(x_size - 1 - x, y)
        end
      end
    end
    @matrix = new_matrix
    @x_size = nil
    @y_size = nil
  end

  def total
    @matrix.flatten.sum
  end
end

def sym(number, axe_index)
  number > axe_index  ? number - 2 * (number - axe_index) : number
end

def process(file)
  grid = Grid.new
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
    regroup_on = fold[:axe] == 'x' ? 1 : 0
    check_on = fold[:axe] == 'x' ? 0 : 1
    lines = all_dots.each_with_object([]) do |dot, lines|
      lines[dot[regroup_on]] ||= []
      lines[dot[regroup_on]] << dot
    end
    lines.select! { |line| line && line.size >= 2 }.each(&:sort!)
    dots_to_remove = lines.each_with_object([]) do |dot_list, dots_to_remove|
      dots_to_remove.concat(dot_list.select do |dot|
        dot[check_on] > fold[:index] && dot_list.any? { |other| other != dot && (fold[:index] - other[check_on]).abs == (fold[:index] - dot[check_on]).abs }
      end)
    end
    all_dots -= dots_to_remove

    all_dots.map! do |dot|
      if fold[:axe] == 'x'
        [sym(dot[0], fold[:index]), dot[1]]
      else
        [dot[0], sym(dot[1], fold[:index])]
      end
    end
    # all_dots.uniq!

    puts "after fold #{fold}, count: #{all_dots.count}"
  end
  x_size = all_dots.map { |d| d[0] }.max
  y_size = all_dots.map { |d| d[1] }.max
  grid = Array.new(y_size+1) { Array.new(x_size+1, ' ') }

  all_dots.each { |x, y| grid[y][x] = '#' }
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