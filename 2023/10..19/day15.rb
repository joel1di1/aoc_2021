# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

init_seq = File.readlines("#{__dir__}/input15.txt", chomp: true).first.split(',')

def m_hash(str)
  val = 0
  str.each_byte do |b|
    val = (17 * (val + b)) % 256
  end
  val
end

puts "part 1: #{init_seq.map { |s| m_hash(s) }.sum}"

class Lens
  attr_reader :label
  attr_accessor :focal_length

  def initialize(label, focal_length = 0)
    @label = label
    @focal_length = focal_length
  end

  def to_s
    "[#{label} #{focal_length}]"
  end

  def inspect
    to_s
  end

  def ==(other)
    label == other.label
  end

  def <=>(other)
    label <=> other.label
  end
end

boxes = Array.new(256) { [] }

init_seq.each do |intruction|
  label, operation, focal_length = intruction.scan(/(\w+)(=|-)(\d*)/).first

  hash_label = m_hash(label)

  boxe = boxes[hash_label]

  case operation
  when '='
    existing_lens = boxe.find { |l| l.label == label }
    if existing_lens
      existing_lens.focal_length = focal_length.to_i
    else
      boxe << Lens.new(label, focal_length.to_i)
    end
  when '-'
    boxe.delete(Lens.new(label))
  else
    raise "Unexpected operation #{operation}"
  end
end


res = boxes.map.with_index do |box, i|
  box.map.with_index do |lens, j|
    lens.focal_length * (i + 1) * (j + 1)
  end
end.flatten.sum

puts "part 2: #{res}"
