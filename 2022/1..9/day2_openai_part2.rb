require 'byebug'
# Read the input file and parse it
def read_and_parse_input_file(filename)
  input = File.readlines(filename).map(&:strip)
  input.map do |line|
    {
      outcome: line[2],
      opponent: line[0]
    }
  end
end

# Calculate the score for a single round
def calculate_round_score(round)
  # Determine the shape to play
  shape = case round[:opponent]
          when "A" then round[:outcome] == "X" ? "C" : round[:outcome] == "Z" ? "B" : "A"
          when "B" then round[:outcome] == "X" ? "A" : round[:outcome] == "Y" ? "B" : "C"
          when "C" then round[:outcome] == "X" ? "B" : round[:outcome] == "Y" ? "C" : "A"
          end

  # Determine the score for the shape
  shape_score = case shape
                when "A" then 1
                when "B" then 2
                when "C" then 3
                end

  # Determine the outcome of the round
  outcome = case round[:outcome]
            when "X" then 0
            when "Y" then 3
            when "Z" then 6
            end

  # Return the total score for the round
  shape_score + outcome
end

# Calculate the total score for a list of rounds
def calculate_total_score(rounds)
  rounds.map { |round| calculate_round_score(round) }.sum
end

# Main function
def main
  input = read_and_parse_input_file("day2.txt")
  puts "Total score: #{calculate_total_score(input)}"
end

main
