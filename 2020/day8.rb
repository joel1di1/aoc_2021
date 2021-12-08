# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

accumulator = 0
commands = File.readlines('day8.txt').map{|line| s = line.split; [s[0], s[1].to_i]}

already_done = Set.new
index = 0

while !already_done.include?(index)
  already_done << index
  command = commands[index]
  case command[0]
  when 'acc'
    accumulator += command[1]
    index += 1
  when 'jmp'
    index += command[1]
  when 'nop'
    index += 1
  end
end

pp accumulator