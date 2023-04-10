# read the input file
moves = File.readlines('day2.txt').map(&:split)

# define the scoring function
def score(player_move, opponent_move)
  player_score = case player_move
                 when 'X' then 1  # Rock
                 when 'Y' then 2  # Paper
                 when 'Z' then 3  # Scissors
                 end
  outcome_score = case [player_move, opponent_move]
                  when ['X', 'C'], ['Y', 'A'], ['Z', 'B'] then 6  # player wins
                  when ['X', 'B'], ['Y', 'C'], ['Z', 'A'] then 0  # player loses
                  else 3  # draw
                  end
  player_score + outcome_score
end

# play the game using the strategy guide
total_score = 0
moves.each do |opponent_move, player_move|
  total_score += score(player_move, opponent_move)
end

puts "Your total score is #{total_score}"
