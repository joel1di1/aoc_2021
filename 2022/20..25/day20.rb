require 'set'
require 'byebug'

$moves = 0

class Number
  attr_reader :value
  attr_accessor :next, :previous, :head

  def initialize(value)
    @value = value
    @head = false
  end

  def move(total_size)
    (value.abs % (total_size-1)).times do
      # if value == 0 do nothing
      next if value == 0

      # link previous to next
      @previous.next = @next
      @next.previous = @previous

      # find the node to insert after
      insert_after = value > 0 ? @next : @previous.previous
      
      # insert self after insert_after
      @next = insert_after.next
      @previous = insert_after
      insert_after.next = self
      @next.previous = self

      $moves += 1
    end
  end

  def to_s
    value.to_s
  end
end

def display(head)
  current = head

  loop do
    print "[#{current.previous.value} <= #{current.value} => #{current.next.value}] "
    current = current.next

    break if head == current
  end
  puts ""
  loop do
    print "#{current.value}, "
    current = current.next

    break if head == current
  end
  puts ""

  current = head
end

[[1, 1], [811589153, 10]].each do |key, mix_number|

  $moves = 0

  numbers = File.readlines('day20.txt').map { |n| n.to_i * key }
  numbers = numbers.map{|number| Number.new(number)}.freeze
  numbers.each_with_index do |number, index|
    number.next = numbers[(index + 1) % numbers.size]
    number.previous = numbers[(index - 1) % numbers.size]
    # puts "number #{number.value} next: #{number.next.value} previous: #{number.previous.value}"
  end

  head = numbers.first
  head.head = true

  # puts "initial:"
  # display(head)

  mix_number.times do
    numbers.each do |number|
      # puts "\n==============move #{number.value}================"
      number.move(numbers.size)
      # display(head)
      # puts ""
    end
  end

  zero = numbers.find{|number| number.value == 0}
  current = zero

  coordinates_positions = [1000, 2000, 3000]
  coordinates = []
  (0..coordinates_positions.max).each do |i|
    if coordinates_positions.include?(i)
      coordinates << current.value
    end
    current = current.next
  end

  puts "coordinates_positions: #{coordinates}, sum: #{coordinates.sum}"
  puts "moves: #{$moves}"
end