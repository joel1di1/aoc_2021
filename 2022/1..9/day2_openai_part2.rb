# Read the input file and parse the strategy guide
strategy_guide = File.readlines("day2.txt").map { |line| line.chomp.split(" ") }

# Initialize the total score
total_score = 0

# Hash to map opponent shapes to numbers
SHAPE_MAP = {
  "A" => 1,
  "B" => 2,
  "C" => 3
}

# Hash to map desired outcomes to numbers
OUTCOME_MAP = {
  "X" => 0,
  "Y" => 3,
  "Z" => 6
}

# Iterate through each round of the game
strategy_guide.each do |opponent_shape, desired_outcome|
  # Initialize the score for the round
  score = 0

  # Determine the shape that you need to play in order to achieve the desired outcome
  case desired_outcome
  when "X"
    your_shape = ((SHAPE_MAP[opponent_shape] - 1 + (-1)) % 3) + 1
  when "Y"
    your_shape = ((SHAPE_MAP[opponent_shape] - 1 + (+0)) % 3) + 1
  when "Z"
    your_shape = ((SHAPE_MAP[opponent_shape] - 1 + (+1)) % 3) + 1
  end

  # Calculate the scores for the outcome and the shape
  outcome_score = OUTCOME_MAP[desired_outcome]
  shape_score = your_shape

  # Add the scores to the score for the round
  score = outcome_score + shape_score

  # Add the score for the round to the total score
  total_score += score
end

# Print the final total score
puts total_score
