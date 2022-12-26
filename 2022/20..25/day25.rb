require 'byebug'
require 'set'
require_relative '../../fwk'

def snafu_to_decimal(str)
  str.chars.reverse.each_with_index.map do |char, index|
    case char
    when '1'
      1 * 5**index
    when '2'
      2 * 5**index
    when '='
      -2 * 5**index
    when '-'
      -1 * 5**index
    when '0'
      0
    else
      raise "Invalid char #{char}"
    end
  end.sum
end

def decimal_to_snafu(decimal)
  result = []
  retenue = 0
  while decimal > 0
    case decimal % 5
    when 0
      result << 0
      retenue = 0
    when 1
      result << 1
      retenue = 0
    when 2
      result << 2
      retenue = 0
    when 3
      result << -2
      retenue = 1
    when 4
      result << -1
      retenue = 1
    when 5
      result << 0
      retenue = 1
    end
    decimal /= 5
    decimal += retenue
    retenue = 0
  end
  result << retenue if retenue > 0
  result.reverse.map{|x| x == -1 ? '-' : (x == -2 ? '=' : x)}.join
end

def tests
  assert_eq 1, snafu_to_decimal('1')
  assert_eq 2, snafu_to_decimal('2')
  assert_eq 3, snafu_to_decimal('1=')
  assert_eq 4, snafu_to_decimal('1-')
  assert_eq 5, snafu_to_decimal('10')
  assert_eq 6, snafu_to_decimal('11')
  assert_eq 7, snafu_to_decimal('12')
  assert_eq 8, snafu_to_decimal('2=')
  assert_eq 9, snafu_to_decimal('2-')
  assert_eq 10, snafu_to_decimal('20')
  assert_eq 15, snafu_to_decimal('1=0')
  assert_eq 20, snafu_to_decimal('1-0')
  assert_eq 2022, snafu_to_decimal('1=11-2')
  assert_eq 12345, snafu_to_decimal('1-0---0')
  assert_eq 314159265, snafu_to_decimal('1121-1110-1=0')

  assert_eq     "1"        , decimal_to_snafu(1)
  assert_eq     "2"        , decimal_to_snafu(2)
  assert_eq     "1="        , decimal_to_snafu(3)
  assert_eq     "1-"        , decimal_to_snafu(4)
  assert_eq     "10"        , decimal_to_snafu(5)
  assert_eq     "11"        , decimal_to_snafu(6)
  assert_eq     "12"        , decimal_to_snafu(7)
  assert_eq     "2="        , decimal_to_snafu(8)
  assert_eq     "2-"        , decimal_to_snafu(9)
  assert_eq     "20"        , decimal_to_snafu(10)
  assert_eq  "1=-0-2"     , decimal_to_snafu(1747)
  assert_eq  "12111"      , decimal_to_snafu(906)
  assert_eq   "2=0="      , decimal_to_snafu(198)
  assert_eq     "21"       , decimal_to_snafu(11)
  assert_eq   "2=01"      , decimal_to_snafu(201)
  assert_eq    "111"       , decimal_to_snafu(31)
  assert_eq  "20012"     , decimal_to_snafu(1257)
  assert_eq    "112"       , decimal_to_snafu(32)
  assert_eq  "1=-1="      , decimal_to_snafu(353)
  assert_eq   "1-12"      , decimal_to_snafu(107)
  assert_eq     "12"        , decimal_to_snafu(7)
  assert_eq     "1="        , decimal_to_snafu(3)
  assert_eq    "122"       , decimal_to_snafu(37)

  puts 'All tests passed'
end

tests

def part1
  snafu_numbers = File.readlines('day25.txt').map(&:strip)
  sum = snafu_numbers.map{|input| snafu_to_decimal(input)}.sum

  puts "Part 1: #{decimal_to_snafu(sum)}"
end

part1