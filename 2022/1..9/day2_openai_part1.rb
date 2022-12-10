# Read the input file and parse it
def read_and_parse_input_file(filename)
  input = File.readlines(filename).map(&:strip)
  input.map do |line|
    {
      opponent: line[0],
      response: line[2]
    }
  end
end

# Calculate the score for a single round
def calculate_round_score(round)
  shape = case round[:response]
          when "X" then 1
          when "Y" then 2
          when "Z" then 3
          end

  outcome = if round[:opponent] == "A" && round[:response] == "Y" ||
              round[:opponent] == "B" && round[:response] == "Z" ||
              round[:opponent] == "C" && round[:response] == "X"
              6
            elsif round[:opponent] == "A" && round[:response] == "X" ||
                  round[:opponent] == "B" && round[:response] == "Y" ||
                  round[:opponent] == "C" && round[:response] == "Z"
                  3
            else
              0
            end

  shape + outcome
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
