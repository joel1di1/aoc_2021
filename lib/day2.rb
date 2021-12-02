require 'readline'

lines = File.readlines('inputs/day2.txt')

commands = lines.map{|line| c = line.split(' '); [c[0], c[1].to_i] }

depth = 0
horizontal = 0

commands.each do |command|
  case command[0]
  when 'forward'
    horizontal += command[1]
  when 'up'
    depth -= command[1]
  when 'down'
    depth += command[1]
  else
    raise 'unkown command'
  end
end

pp "depth: #{depth}, horizontal: #{horizontal}"
pp depth * horizontal

########################################

depth = 0
horizontal = 0
aim = 0

commands.each do |command|
  case command[0]
  when 'forward'
    horizontal += command[1]
    depth += aim * command[1]
  when 'up'
    aim -= command[1]
  when 'down'
    aim += command[1]
  else
    raise 'unkown command'
  end
end

pp "depth: #{depth}, horizontal: #{horizontal}"
pp depth * horizontal
