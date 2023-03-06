# Read the input file and parse the strategy guide
strategy_guide = []
File.open("day2.txt") do |file|
  file.each_line do |line|
    strategy_guide << line.chomp.split(" ")
  end
end

# Initialize the total score
total_score = 0

# Hash to map shapes to numbers
shape_map = {
  "A" => 1,
  "B" => 2,
  "C" => 3,
  "X" => 1,
  "Y" => 2,
  "Z" => 3
}

# Iterate through each round of the game
strategy_guide.each do |round|
  # Determine the shape that your opponent will play and the shape that you should play according to the strategy guide
  opponent_shape = round[0]
  your_shape = round[1]

  # Calculate the score for the round
  if shape_map[opponent_shape] == shape_map[your_shape]
    # The round is a draw
    score = 3
  elsif (shape_map[opponent_shape] == 1 && shape_map[your_shape] == 2) || (shape_map[opponent_shape] == 2 && shape_map[your_shape] == 3) || (shape_map[opponent_shape] == 3 && shape_map[your_shape] == 1)
    # You win
    score = 6
  else
    # You lose
    score = 0
  end
  # Add the value corresponding to the shape that you selected to the score
  score += shape_map[your_shape]

  # Add the score for the round to the total score
  total_score += score
end

# Print the final total score
puts total_score
