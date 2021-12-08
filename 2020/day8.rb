# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

COMMANDS = File.readlines('day8.txt').map { |line| s = line.split; [s[0], s[1].to_i] }

def process
  processed = Set.new
  index = 0
  accumulator = 0

  until processed.include?(index) || index == COMMANDS.count
    processed << index

    command = COMMANDS[index]
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
  [accumulator, processed]
end

accumulator, processed = process

puts "part1: #{accumulator}"

def select_previous(end_index)
  (0..COMMANDS.size-1).select do |index|
    command = COMMANDS[index]
    (index + 1 == end_index && ['acc', 'nop'].include?(command[0])) ||
      (command[0] == 'jmp' && (index + command[1]) == end_index)
  end
end

def op_to_change_change(processed, end_index = COMMANDS.count)
  processed.select do |index|
    command = COMMANDS[index]
    (command[0] == 'nop' && index + command[1] == end_index) ||
      (index if command[0] == 'jmp' && index + 1 == end_index)
  end
end

previous = [COMMANDS.count]
until previous.empty?
  prev = previous.shift
  sols = op_to_change_change(processed, prev)
  break unless sols.empty?

  previous += select_previous(prev)
end
sol = sols.first
puts "to_change: #{sol}, #{COMMANDS[sol]}"

COMMANDS[sol][0] = COMMANDS[sol][0] == 'jmp' ? 'nop' : 'jmp'

accumulator, processed = process

puts "part2: #{accumulator}"