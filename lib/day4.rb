#  ❯ bundle exec ruby lib/day4.rb                                                                       [16:57:07]
# First winner is 51, score: 11536
# last winner is 87, score: 1284

require 'readline'
require 'pry'

class Cell
  attr_reader :number
  attr_reader :row
  attr_reader :col

  def initialize(number, row, col)
    @number = number
    @row = row
    @col = col
    @marked = false
  end

  def mark!
    @marked = true
  end

  def marked?
    @marked
  end

  def to_s
    return "\033[32m%02d\033[0m" % @number if marked?
    "%02d" % @number
  end
end

class Board
  attr_reader :index
  attr_reader :won

  def initialize(numbers, index)
    @won = false
    @index = index
    @rows = []
    @cols = []
    @cell_by_number = {}
    @board = numbers.map.with_index do |row, i|
      row.map.with_index do |num, j|
        row = @rows[i] || (@rows[i] = [])
        col = @cols[j] || (@cols[j] = [])
        cell = Cell.new(num, row, col)
        @cell_by_number[num] = cell
        row << cell
        col << cell
        cell
      end
    end
  end

  def cell(i, j)
    @board[i][j]
  end

  def mark!(number)
    return if @won
    cell = @cell_by_number[number]
    return if cell.nil?

    cell.mark!
    if cell.row.all? {|c| c.marked?} || cell.col.all? {|c| c.marked?}
      @won = true
      return self
    end
    nil
  end

  def score
    @rows.map{|row| row.map{|cell| cell.marked? ? 0 : cell.number }.reduce(:+)}.reduce(:+)
  end

  def to_s
    "BOARD ##{@index}\n" +
      @board.map{|row| row.map{|cell| cell.to_s}.join(' ') }.join("\n")
  end
end


lines = File.readlines('inputs/day4.txt')

draw_numbers = lines[0].split(',').map(&:to_i)

boards = []
lines[2..-1].each_slice(6).with_index do |slice, index|
  boards << Board.new(slice[0, 5].map{|raw| raw.split().map(&:to_i)}, index)
end

no_wins = (0..boards.length - 1).to_a

last_winner = nil
win_draw = nil
first_winner = nil
already_wins = []

draw_numbers.each do |draw|
  # puts "-- DRAW #{draw}"
  new_winners = boards.map{|board| board.mark!(draw) }.compact
  # puts "Boards: #{boards.map(&:to_s).join("\n")}"
  # puts "found winners: #{new_winners.map(&:index)}"
  if first_winner.nil? && !new_winners.empty?
    first_winner = new_winners.first
    puts "First winner is #{first_winner}\nscore: #{first_winner.score * draw}"
  end
  if !new_winners.empty?
    last_winner = new_winners.last
    no_wins = no_wins - new_winners.map(&:index)
    already_wins += new_winners.map(&:index)
    win_draw = draw
    break if no_wins.length == 0
  end
  # puts "no wins: #{no_wins}"
end

puts "last winner is #{last_winner}\nscore: #{last_winner.score * win_draw}"
