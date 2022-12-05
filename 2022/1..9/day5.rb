# frozen_string_literal: true

def init_stacks(stacklines)
  stacks = []
  stacklines.reverse.each do |line|
    stack_index = 0

    while stack_index * 4 < line.length
      char_at_index = line[1 + (4 * stack_index)]

      stack_index += 1
      stacks[stack_index] ||= []
      stacks[stack_index] << char_at_index unless char_at_index.nil? || char_at_index.strip == ''
    end
  end
  stacks
end

lines = File.readlines('day5.txt')
stacklines = lines.select { |line| line[/\[/] }
move_lines = lines.select { |line| line.start_with?('move') }

stacks = init_stacks(stacklines)

move_lines.each do |line|
  nb, origin, target = line.match(/move (\d+) from (\d+) to (\d+)/).captures
  nb.to_i.times do
    stacks[target.to_i] << stacks[origin.to_i].pop
  end
end

part1 = stacks.map { |stack| stack&.last }.join
puts "part1: #{part1}"

#############################################

stacks = init_stacks(stacklines)

move_lines.select { |line| line.start_with?('move') }.each do |line|
  nb, origin, target = line.match(/move (\d+) from (\d+) to (\d+)/).captures
  stacks[target.to_i].append(* stacks[origin.to_i].pop(nb.to_i))
end

part1 = stacks.map { |stack| stack&.last }.join
puts "part2: #{part1}"
