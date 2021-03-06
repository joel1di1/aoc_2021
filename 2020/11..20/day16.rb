# frozen_string_literal: true

require_relative '../../fwk'

class Ticket
  def initialize(numbers)
    @numbers = numbers.freeze
  end

  def [](index)
    @numbers[index]
  end

  def all_invalid?(number, rules)
    rules.all? { |rule| rule.invalid?(number) }
  end

  def invalid_value(rules)
    invalids = @numbers.select { |number| all_invalid?(number, rules) }
    raise "many invalid values in #{@numbers}" if invalids.size > 1

    invalids.first
  end
end

class Rule
  attr_reader :field

  def initialize(field, ranges)
    @ranges = [*ranges].freeze
    @field = field
  end

  def invalid?(number)
    @ranges.all? { |range| !range.include?(number) }
  end

  def valid?(number)
    !invalid?(number)
  end
end

# rule = Rule.new('first', 10..20, 30..40)
# assert !rule.invalid?(10)
# assert !rule.invalid?(40)
# assert rule.invalid?(41)
# assert rule.invalid?(21)
#
# rule2 = Rule.new('second', 1..10)
# ticket = Ticket.new([1, 11, 60])
#
# assert_eq 60, ticket.invalid_value([rule, rule2])

def inputs(file)
  file_lines = File.readlines(file).map(&:strip)
  rules = []
  tickets = []
  my_ticket = nil
  file_lines.each do |line|
    case line
    when /^\d/
      ticket = Ticket.new(line.split(',').map(&:to_i))
      my_ticket ||= ticket
      tickets << ticket
    when /tickets?:$/
    when /: /
      split = line.split(':')
      ranges = split[1].split(' or ').map do |range_str|
        split2 = range_str.split('-')
        (split2[0].to_i..split2[1].to_i)
      end
      rules << Rule.new(split[0], ranges)
    end
  end
  [my_ticket, rules, tickets]
end

def process(file)
  my_ticket, rules, tickets = inputs(file)

  sum = tickets.map { |ticket| ticket.invalid_value(rules) }.compact.sum
  puts "#{file}, sum: #{sum}"

  tickets.select! { |ticket| ticket.invalid_value(rules).nil? }

  ordered_rules = []
  (0..rules.size - 1).each do |i|
    ordered_rules[i] = rules.select do |rule|
      tickets.all? { |ticket| rule.valid?(ticket[i]) }
    end
  end

  until ordered_rules.all? { |candidates| candidates.size == 1 }
    uniques = ordered_rules.map { |candidates| candidates.first if candidates.size == 1 }.compact
    uniques.each do |uniq|
      to_remove = ordered_rules.select { |candidates| candidates.size > 1 && candidates.include?(uniq) }
      to_remove.each {|candidates| candidates.delete(uniq) }
    end
  end

  mult = 1
  ordered_rules.map!(&:first).each_with_index do |rule, index|
    mult *= my_ticket[index] if rule.field.start_with?('departure')
  end

  puts "mult: #{mult}"

end

process('day16_sample.txt')
process('day16.txt')
