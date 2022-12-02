# frozen_string_literal: true
require 'readline'

def read_input_lines
  File.readlines(File.basename(__FILE__).gsub('.rb', '.txt'))
end

results = {
  'X' => {'A' => 3, 'B' => 0, 'C' => 6}, 
  'Y' => {'A' => 6, 'B' => 3, 'C' => 0}, 
  'Z' => {'A' => 0, 'B' => 6, 'C' => 3}, 
}

score1 = read_input_lines.map do |game|
  adv, play = game.split
  results[play][adv] + (play.ord - 'X'.ord + 1)
end.sum

puts "1st part: #{score1}"

results2 = {
  'X' => {'A' => 3, 'B' => 1, 'C' => 2}, 
  'Y' => {'A' => 4, 'B' => 5, 'C' => 6}, 
  'Z' => {'A' => 8, 'B' => 9, 'C' => 7}, 
}

score2 = read_input_lines.map do |game|
  adv, play = game.split
  results2[play][adv]
end.sum

puts "2nd part: #{score2}"
