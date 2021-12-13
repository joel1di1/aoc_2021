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

def process(file)
  grid = Grid.new
  lines = File.readlines(file).map(&:strip)

  lines.select { |l| l[/^\d+,\d/] }.each do |line|
    x, y = line.scan(/^(\d+),(\d+)/)[0].map(&:to_i)
    grid.mark(x, y)
  end
  folds =
    lines.select { |l| l[/fold along (x|y)=(\d+)/] }.map do |line|
      scan = line.scan(/fold along (x|y)=(\d+)/)
      { axe: scan[0][0], index: scan[0][1].to_i }
    end

  grid.fill_empty
  grid.display('after fill _empty')
  grid.apply_fold(folds.first)
  grid.display('after first_fold')

  # folds.each do |fold|
  #   grid.apply_fold(fold)
  #   break
  # end

  puts "\nSUM: #{grid.total}"
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