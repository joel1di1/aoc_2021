# frozen_string_literal: true

# Define the method to initialize the stacks
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

# First, let's read the input from day5.txt file
lines = File.readlines('day5.txt')
stacklines = lines.select { |line| line[/\[/] }
move_lines = lines.select { |line| line.start_with?('move') }

# Let's initialize the stacks array
stacks = init_stacks(stacklines)

# Let's parse the moves and apply them to the stacks array
moves = move_lines.map do |move|
  nb, origin, target = move.match(/move (\d+) from (\d+) to (\d+)/).captures
  [origin.to_i - 1, target.to_i - 1, nb.to_i]
end

moves.each do |origin, target, nb|
  nb.times do
    stacks[target] << stacks[origin].pop
  end
end

# Let's get the top crate from each stack and print the result
result = stacks.map(&:last).join('')
puts result
