# frozen_string_literal: true

require 'byebug'
require 'readline'

def process(file)
  commands = File.readlines(file).map{|l| l.scan(/(\w)(\d+)/).flatten}

  directions = ['N', 'E', 'S', 'W']
  head = 1 # facing east

  north = 0
  east = 0
  commands.each do |command|
    num = command[1].to_i
    case command.first == 'F' ? directions[head] : command.first
    when 'N'
      north += num
    when 'S'
      north -= num
    when 'E'
      east += num
    when 'W'
      east -= num
    when 'L'
      head = (head - num / 90) % 4
    when 'R'
      head = (head + num / 90) % 4
    when 'F'
      north -= num
    end
  end

  east.abs + north.abs
end

puts process( 'day12_sample.txt')
puts process( 'day12.txt')
