# frozen_string_literal

require 'byebug'

class Monkey
  attr_accessor :operation, :divider, :next_true, :next_false, :items, :inspected

  def initialize()
    @operation = nil
    @divider = nil
    @next_true = nil
    @next_false = nil
    @next_false = nil
    @inspected = 0
  end

  def apply_op(old)
    new = nil
    eval(@operation)
    new
  end

  def turn!(relief = true)
    @inspected += @items.size
    while @items.size > 0
      worry = @items[0]
      @items = @items[1..]
      worry = apply_op(worry)
      worry = worry  / 3 if relief
      worry = worry % $max

      $monkeys[worry % @divider == 0 ? next_true : next_false].items << worry
    end
  end
end

def init_monkeys
  current_monkey = nil
  monkeys = []
  File.readlines('day11.txt').map(&:strip).each do |line|
    case line
    when /Monkey/
      current_monkey = Monkey.new 
      monkeys << current_monkey
    when /Operation: (.*)/
      operation = $1
      current_monkey.operation = operation
    when /Starting items: (.*)/
      current_monkey.items = $1.scan(/(\d+)/).flatten.map(&:to_i)
    when /Test: divisible by (\d+)/
      current_monkey.divider = $1.to_i
    when /If true: throw to monkey (\d+)/
      current_monkey.next_true = $1.to_i
    when /If false: throw to monkey (\d+)/
      current_monkey.next_false = $1.to_i
    when ''
    else
      raise "ERREUR: #{line}"
    end
  end
  monkeys
end

$monkeys = init_monkeys
$max = $monkeys.map(&:divider).inject(&:*)

20.times do |turn|
  $monkeys.map(&:turn!)
  # puts "\nafter turn #{turn}"
  # $monkeys.each_with_index do |monkey, i|
  #   puts "Monkey #{i}: #{monkey.items}"
  # end
end

puts "Part 1 : #{$monkeys.map(&:inspected).sort.reverse[0..1].inject(&:*)}"

$monkeys = init_monkeys

puts $max

10_000.times do |turn|
  puts "-- turn #{turn}" if turn % 10 == 0
  if turn % 20 == 0
    puts($monkeys.map(&:inspected))
    $monkeys.each do |monkey|
      pp monkey.items
    end
  end
  $monkeys.map { |monkey| monkey.turn!(false) }
end
puts "Part 2 : #{$monkeys.map(&:inspected).sort.reverse[0..1].inject(&:*)}"


