require 'readline'

lines = File.readlines('inputs/day4.txt')

draw_numbers = lines[0].split(',').map(&:to_i)

boards = []
lines[2..-1].each_slice(6) do |slice|
  boards << slice[0, 5].map{|raw| raw.split().map(&:to_i)}
end
