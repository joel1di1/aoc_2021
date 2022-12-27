# Read the input file and parse the strategy guide
strategy_guide = File.readlines("day2.txt").map { |line| line.chomp.split(" ") }

# Initialize the total score
total_score = 0

# Hash to map shapes to numbers
SHAPE_MAP = {
  "A" => 1,
  "B" => 2,
  "C" => 3,
  "X" => 1,
  "Y" => 2,
  "Z" => 3
}

# Iterate through each round of the game
strategy_guide.each do |opponent_shape, your_shape|
  # Initialize the score for the round
  score = 0

  # Calculate the score for the round
  case SHAPE_MAP[your_shape] - SHAPE_MAP[opponent_shape]
  when -2, 1
    # You win
    score = 6
  when -1, 2
    # You lose
    score = 0
  when 0
    # The round is a draw
    score = 3
  end
  # Add the value corresponding to the shape that you selected to the score
  score += SHAPE_MAP[your_shape]

  # Add the score for the round to the total score
  total_score += score
end

# Print the final total score
puts total_score
