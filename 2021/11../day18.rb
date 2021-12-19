# frozen_string_literal: true

require_relative '../../fwk'

class Integer
  def depth
    -Float::INFINITY
  end
end

class SnailNumber
  attr_reader :left, :right

  def self.call(str)
    array = eval(str)
    SnailNumber.new(array[0], array[1])
  end

  def initialize(left, right)
    @left = left.is_a?(Array) ? SnailNumber.new(left[0], left[1]) : left
    @right = right.is_a?(Array) ? SnailNumber.new(right[0], right[1]) : right
    @starred = nil
  end

  def depth
    [left, right].map do |num|
      num.is_a?(SnailNumber) ? num.depth + 1 : 0
    end.max
  end

  def is_reduced?
    depth < 4
  end

  def replace_by_zero!(num)
    if left == num
      @left = 0
      @starred = :left
    else
      @right = 0
      @starred = :right
    end
  end

  def explode!
    chain = first_chain_to_explode

    zeroed = chain[-2]
    zeroed.replace_by_zero!(chain.last)

    left_str, rigth_str = to_s.scan(/(.*)&(.*)/)[0]

    new_rigth_str = propagate_right(rigth_str, chain.last.right)
    new_left_str = propagate_left(left_str, chain.last.left)

    str = new_left_str + '0' + new_rigth_str
    # puts "exploded:#{str}"
    new_num = SnailNumber.(str)
    return new_num unless new_num.need_explosion?
    new_num.explode!
  end

  def first_chain_to_explode
    chain = [self]

    min_depth = 3
    current = self
    until current.left.is_a?(Integer) && current.right.is_a?(Integer)
      c_left = current.left
      c_right = current.right
      chain << ((c_left.depth >= min_depth) ? c_left : c_right)

      current = chain.last
      min_depth -= 1
    end
    chain
  end

  def propagate_left(str, num)
    reversed = str.reverse
    scan = reversed.scan(/([\[\],]*)(\d*)(.*)/)[0]
    middle = scan[1].empty? ? '' : (scan[1].reverse.to_i + num).to_s
    scan[2].reverse + middle + scan[0].reverse
  end

  def propagate_right(str, num)
    scan = str.scan(/([\[\],]*)(\d*)(.*)/)[0]
    middle = scan[1].empty? ? '' : (scan[1].to_i + num).to_s
    scan[0] + middle + scan[2]
  end

  def split!
    s = to_s
    i = s[/\d{2}/].to_i
    l = i / 2
    r = i - l
    str = s.sub(/\d{2}/, "[#{l},#{r}]")
    # puts "splitted:#{str}"
    SnailNumber.(str)
  end

  def need_split?
    to_s[/\d\d/]
  end

  def need_explosion?
    depth >= 4
  end

  def reduce!
    tmp = self
    while tmp.need_explosion? || tmp.need_split?
      tmp = tmp.explode! if tmp.need_explosion?
      tmp = tmp.split! if tmp.need_split?
    end
    tmp
  end

  def ==(other)
    self.class == other.class && to_s == other.to_s
  end

  def to_s
    "[#{@starred == :left ? '&' : left.to_s},#{@starred == :right ? '&' : right.to_s}]"
  end

  def +(other)
    SnailNumber.new(self, other).reduce!
  end

  def magnitude
    left * 3 + right * 2
  end

  def *(other)
    magnitude * other
  end
end

def assert_parse(str)
  assert_eq str, SnailNumber.(str).to_s
end

def assert_sum(expected, str)
  assert_eq expected, sum(str).to_s
end

def tests
  #   assert_parse '[1,2]'
  #   assert_parse '[[1,2],3]'
  #   assert_parse '[9,[8,7]]'
  #   assert_parse '[[1,9],[8,5]]'
  #   assert_parse '[[[[1,2],[3,4]],[[5,6],[7,8]]],9]'
  #   assert_parse '[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]'
  #   assert_parse '[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]'
  #
  #   assert_eq '[[1,2],[[3,4],5]]', (SnailNumber.('[1,2]') + SnailNumber.('[[3,4],5]')).to_s
  #   assert_eq '[[9,[8,7]],[[1,9],[8,5]]]', (SnailNumber.('[9,[8,7]]') + SnailNumber.('[[1,9],[8,5]]')).to_s
  #
  #   assert_eq '[[[[0,9],2],3],4]', SnailNumber.('[[[[[9,8],1],2],3],4]').reduce!.to_s
  #   assert_eq '[7,[6,[5,[7,0]]]]', SnailNumber.('[7,[6,[5,[4,[3,2]]]]]').reduce!.to_s
  #   assert_eq '[[3,[2,[8,0]]],[9,[5,[7,0]]]]', SnailNumber.('[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]').reduce!.to_s
  #
  #   sum = SnailNumber.('[1,1]') + SnailNumber.('[2,2]') + SnailNumber.('[3,3]') + SnailNumber.('[4,4]')
  #   assert_eq '[[[[1,1],[2,2]],[3,3]],[4,4]]', sum.to_s
  #
  #   assert_eq '[[[[0,7],4],[[7,8],[6,0]]],[8,1]]', (SnailNumber.('[[[[4,3],4],4],[7,[[8,4],9]]]') + SnailNumber.('[1,1]')).to_s
  #
  #   assert_sum('[[[[1,1],[2,2]],[3,3]],[4,4]]', <<TEXT)
  # [1,1]
  # [2,2]
  # [3,3]
  # [4,4]
  # TEXT
  #   assert_sum('[[[[3,0],[5,3]],[4,4]],[5,5]]', <<TEXT)
  # [1,1]
  # [2,2]
  # [3,3]
  # [4,4]
  # [5,5]
  # TEXT
  #   assert_sum('[[[[5,0],[7,4]],[5,5]],[6,6]]', <<TEXT)
  # [1,1]
  # [2,2]
  # [3,3]
  # [4,4]
  # [5,5]
  # [6,6]
  # TEXT
  #
  #   assert_sum('[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]', <<TEXT)
  # [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
  # [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
  # TEXT
  #
  #   assert_eq '[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]', (SnailNumber.('[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]') + SnailNumber.('[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]')).to_s
  #   assert_eq '[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]', (SnailNumber.('[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]')  + SnailNumber.('[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]')).to_s
  #   assert_eq '[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]', (SnailNumber.('[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]') + SnailNumber.('[7,[5,[[3,8],[1,4]]]]')).to_s
  #   assert_eq '[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]', (SnailNumber.('[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]')  + SnailNumber.('[[2,[2,2]],[8,[8,1]]]')).to_s
  #   assert_eq '[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]', (SnailNumber.('[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]') + SnailNumber.('[2,9]')).to_s
  #   assert_eq '[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]', (SnailNumber.('[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]')  + SnailNumber.('[1,[[[9,3],9],[[9,0],[0,7]]]]')).to_s
  #   assert_eq '[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]', (SnailNumber.('[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]') + SnailNumber.('[[[5,[7,4]],7],1]')).to_s
  #   assert_eq '[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]', (SnailNumber.('[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]')  + SnailNumber.('[[[[4,2],2],6],[8,7]]')).to_s
  #
  #   assert_sum('[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]', <<TEXT)
  # [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
  # [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
  # [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
  # [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
  # [7,[5,[[3,8],[1,4]]]]
  # [[2,[2,2]],[8,[8,1]]]
  # [2,9]
  # [1,[[[9,3],9],[[9,0],[0,7]]]]
  # [[[5,[7,4]],7],1]
  # [[[[4,2],2],6],[8,7]]
  # TEXT

  assert_eq 143, SnailNumber.('[[1,2],[[3,4],5]]').magnitude
  assert_eq 1384, SnailNumber.('[[[[0,7],4],[[7,8],[6,0]]],[8,1]]').magnitude
  assert_eq 445, SnailNumber.('[[[[1,1],[2,2]],[3,3]],[4,4]]').magnitude
  assert_eq 791, SnailNumber.('[[[[3,0],[5,3]],[4,4]],[5,5]]').magnitude
  assert_eq 1137, SnailNumber.('[[[[5,0],[7,4]],[5,5]],[6,6]]').magnitude
  assert_eq 3488, SnailNumber.('[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]').magnitude

  text = <<TEXT
  [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
  [[[5,[2,8]],4],[5,[[9,9],0]]]
  [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
  [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
  [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
  [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
  [[[[5,4],[7,7]],8],[[8,3],8]]
  [[9,3],[[9,9],[6,[4,9]]]]
  [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
  [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
TEXT
  assert_eq 3993, max_2_sum(text)
  puts "\n TESTS OK!\n"
end

def sum(text)
  num_strs = text.split
  nums = num_strs.map { |str| SnailNumber.(str.strip) }
  nums.reduce(:+)
end

def max_2_sum(text)
  num_strs = text.split
  nums = num_strs.map(&:strip)

  nums.map.with_index do |n1, i|
    nums.map.with_index do |n2, j|
      puts "(i,j) = (#{i}, #{j})" if j % 10 == 0
      next if n1 == n2

      (SnailNumber.(n1) + SnailNumber.(n2)).magnitude
    end
  end.flatten.compact.max
end

# tests
# sum_day18 = sum(File.read('day18.txt').strip)
# puts "magnitude: #{sum_day18.magnitude}"

puts "max sum: #{max_2_sum(File.read('day18.txt'))}"