# frozen_string_literal: true

require 'byebug'
require 'readline'

def process(file)
  commands = File.readlines(file).map{|l| l.scan(/(\w)(\d+)/).flatten}

  waypoint = [10, 1] # EAST, NORTH

  north = 0
  east = 0
  commands.each do |command|
    puts "current pos-- east:#{east}, north:#{north}, waypoint: #{waypoint}"
    puts "applying command: #{command}"
    num = command[1].to_i
    case command.first
    when 'N'
      waypoint[1] += num
    when 'S'
      waypoint[1] -= num
    when 'E'
      waypoint[0] += num
    when 'W'
      waypoint[0] -= num
    when 'L'
      ((num / 90) % 4).times do
        waypoint = [-waypoint[1], waypoint[0]]
      end
    when 'R'
      ((num / 90) % 4).times do
        waypoint = [waypoint[1], -waypoint[0]]
      end
    when 'F'
      east += num * waypoint[0]
      north += num * waypoint[1]
    end
  end

  east.abs + north.abs
end

puts process( 'day12_sample.txt')
puts process( 'day12.txt')
