# frozen_string_literal: true

require_relative '../../fwk'

class OrderRule
  def initialize(str)
    @list = str.split.map(&:to_i)
  end

  def to_re(rules, str_rules)
    @list.map { |rule_index| convert_rule(rule_index, rules, str_rules) }.join
  end
end

class OrRule
  def initialize(str1, str2)
    @left_list = str1.split.map(&:to_i)
    @right_list = str2.split.map(&:to_i)
  end

  def to_re(rules, str_rules)
    left = @left_list.map { |rule_index| convert_rule(rule_index, rules, str_rules) }.join
    right = @right_list.map { |rule_index| convert_rule(rule_index, rules, str_rules) }.join
    "((#{left})|(#{right}))"
  end
end

class ReRule
  def initialize(str)
    @re = str
  end

  def to_re(_rules, _str_rules)
    @re
  end
end

def convert_rule(index, rules, str_rules)
  str_rules[index] ||= rules[index].to_re(rules, str_rules)
end

def readinputs(file)
  lines = File.readlines(file)
  rules = []
  messages = []
  lines.each do |line|
    line = line.strip
    case line
    when /^(\d+):(.*)\|(.*)$/
      match = Regexp.last_match
      rules[match[1].to_i] = OrRule.new(match[2], match[3])
    when /^(\d+): ([\d\s]+)$/
      match = Regexp.last_match
      rules[match[1].to_i] = OrderRule.new match[2]
    when /^(\d+): "([ab])"$/
      match = Regexp.last_match
      rules[match[1].to_i] = ReRule.new match[2]
    when /^([ab]+)$/
      messages << line
    when ''
    else
      raise "Unrecognized: #{line}"
    end
  end
  [rules, messages]
end

rules, messages = readinputs('day19.txt')
str_rules = []
(0..rules.size - 1).each do |i|
  str_rules[i] ||= convert_rule(i, rules, str_rules)
end

pp messages.select{|msg| msg[/^#{str_rules[0]}$/]}.count