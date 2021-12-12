# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def neighbors(size, i, j)
  [[i - 1, j - 1], [i - 1, j], [i - 1, j + 1],
   [i, j - 1], [i, j + 1],
   [i + 1, j - 1], [i + 1, j], [i + 1, j + 1]].select do |x, y|
    x >= 0 && y >= 0 && x <= size - 1 && y <= size - 1
  end
end

def red
  printf "\033[31m"
  yield
  printf "\033[0m"
end

def display(octopuses)
  octopuses.each do |octopus_line|
    octopus_line.each do |o|
      if o == 0
        red { print o }
      else
        print o
      end
    end
    print "\n"
  end
  print "\n"
end

def process(file)
  lines = File.readlines(file)
  octopuses = lines.map { |l| l.strip.chars.map(&:to_i) }
  size = lines.size
  nb_flashes = 0
  (0..).each do |iteration|
    if octopuses.map(&:sum).sum == size * size
      puts "all flashes: #{iteration}"
      return
    end
    display(octopuses)
    flashes_os_matrix = octopuses.map.with_index do |l, i|
      l.map.with_index do |_o, j|
        octopuses[i][j] += 1
        octopuses[i][j] > 9 ? (nb_flashes += 1; [i, j]) : nil
      end
    end
    flashes_os = []
    flashes_os_matrix.each { |line| line.each { |coord| flashes_os << coord if coord } }
    until flashes_os.empty? do
      flashes_os_matrix = flashes_os.map do |i, j|
        neighbors(size, i, j).map do |neighbor_i, neighbor_j|
          octopuses[neighbor_i][neighbor_j] += 1
          octopuses[neighbor_i][neighbor_j] == 10 ? (nb_flashes += 1; [neighbor_i, neighbor_j]) : nil
        end
      end
      flashes_os = []
      flashes_os_matrix.each { |line| line.each { |coord| flashes_os << coord if coord } }
    end
    (0..size - 1).each { |i| (0..size - 1).each { |j| octopuses[i][j] = 0 if octopuses[i][j] > 9 } }
  end

  puts "#{file} flashes: #{nb_flashes}"
end

process('day11_sample.txt')
process('day11.txt')
