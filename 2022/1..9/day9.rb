# frozen_string_literal: true

require 'byebug'
require 'set'

moves = File.readlines('day9.txt').map(&:strip).map do |line| 
  # debugger if line.match(/(\w) (\d+)/).nil?
  capts = line.match(/(\w) (\d+)/).captures
  [capts[0], capts[1].to_i]
end

class Pos 
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def <=>(other)
    @x <=> other.x && @y <=> other.y
  end

  def ==(other) 
    @x == other.x && @y == other.y
  end

  def move(move)
    new_x, new_y = 0, 0
    case move
    when 'U'
      new_x, new_y = @x, @y+1
    when 'D'
      new_x, new_y = @x, @y-1
    when 'R'
      new_x, new_y = @x+1, @y
    when 'L'
      new_x, new_y = @x-1, @y
    when 'UL'
      new_x, new_y = @x-1, @y+1
    when 'UR'
      new_x, new_y = @x+1, @y+1
    when 'DL'
      new_x, new_y = @x-1, @y-1
    when 'DR'
      new_x, new_y = @x+1, @y-1
    end
    Pos.new(new_x, new_y)
  end

  def go_toward(pos)
    y_diff = pos.y - @y
    x_diff = pos.x - @x

    return self if y_diff.abs <= 1 && x_diff.abs <= 1

    Pos.new(x_diff > 0 ? @x+1 : (x_diff < 0 ? @x-1 : @x), y_diff > 0 ? @y+1 : (y_diff < 0 ? @y-1 : @y))
  end

  def to_s
    "(#{@x},#{@y})"
  end
end


class Rope
  attr_reader :same_positions

  TAIL_LENGTH = 10

  def initialize
    @knots = []
    TAIL_LENGTH.times{ @knots << Pos.new(0,0) }
    @same_positions = Set.new
  end

  def move(move)
    @knots[0] = @knots[0].move(move)

    (1..TAIL_LENGTH-1).each do |i|
      @knots[i] = @knots[i].go_toward(@knots[i-1])
    end

    # puts "move: #{move} [#{@head},#{@tail}], , [#{new_head}, #{new_tail}]"

    # @tail = new_tail
    # @head = new_head

    @same_positions << @knots[-1]
  end
end

rope = Rope.new

moves.each do |move|
  move.last.times do
    rope.move(move.first)
  end
end

puts rope.same_positions.map(&:to_s).uniq.sort
puts rope.same_positions.map(&:to_s).uniq.size