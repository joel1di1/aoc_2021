require 'readline'
require 'pry'

lines = File.readlines('inputs/day4.txt')

draw_numbers = lines[0].split(',').map(&:to_i)

boards = []
lines[2..-1].each_slice(6) do |slice|
  boards << slice[0, 5].map{|raw| raw.split().map(&:to_i)}
end


marks = Array.new(boards.count) {Array.new(5){Array.new(5, 0)}}


def mark_all_boards(boards, marks, draw)
  (0..boards.length - 1).each do |board_index|
    (0..4).each do |i|
      (0..4).each do |j|
        marks[board_index][i][j] = 1 if boards[board_index][i][j] == draw
      end
    end
  end
end

def search_for_new_winners(marks, already_wins)
  # binding.pry if !already_wins.empty?
  new_winners = []
  ((0..marks.length - 1).to_a - already_wins).each do |board_index|
    (0..4).each do |i|
      # check row
      new_winners << board_index if marks[board_index][i].sum == 5
      # check col
      new_winners << board_index if (0..4).map{|j| marks[board_index][j][i]}.sum == 5
    end
  end
  new_winners
end

def calculate_score(board, mark)
  score = 0
  (0..4).each do |i|
    (0..4).each do |j|
      score += board[i][j] if mark[i][j].zero?
    end
  end
  score
end

def show_boards(boards, marks)
  (0..boards.length - 1).each do |board_index|
    puts "\n\t BOARD #{board_index}"
    (0..4).each do |i|
      puts boards[board_index][i].map{|num| "%02d" % num}.join(' ') + "  " + marks[board_index][i].join(' ')
    end
  end
  "OK"
end

no_wins = (0..boards.length - 1).to_a

last_winner = nil
win_draw = nil
first_winner = nil
already_wins = []

draw_numbers.each do |draw|
  puts "-- DRAW #{draw}"
  mark_all_boards(boards, marks, draw)
  # show_boards(boards, marks)
  new_winners = search_for_new_winners(marks, already_wins)
  puts "found winners: #{new_winners}"
  if first_winner.nil? && !new_winners.empty?
    first_winner = new_winners.first
    winner_score = calculate_score(boards[first_winner], marks[first_winner])
    puts "First winner is #{first_winner}, score: #{winner_score * draw}"
  end
  if !new_winners.empty?
    last_winner = new_winners.last
    no_wins = no_wins - new_winners
    already_wins += new_winners
    win_draw = draw
    break if no_wins.length == 0
  end
  puts "no wins: #{no_wins}"
end

winner_score = calculate_score(boards[last_winner], marks[last_winner])
puts "last winner is #{last_winner}, score: #{winner_score * win_draw}"
