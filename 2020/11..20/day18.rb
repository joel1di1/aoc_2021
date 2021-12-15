# frozen_string_literal: true

require_relative '../../fwk'

def evaluate(str)
  puts "evaluate #{str}"
  str = str.gsub(/\s/, '')
  while match = str.scan(/(\(([^()]+)\))/)[0]
    str = str.sub(match[0], evaluate(match[1]).to_s)
    puts "gsubed( #{str}"
  end

  while match = str.scan(/(\d+[+]\d+)/)[0]
    str = str.sub(match[0], eval(match[0]).to_s)
    puts "gsubed+ #{str}"
  end

  res = eval(str)
  puts "eval #{res}"
  res
end

assert_eq 6, evaluate('2 * 3')
assert_eq 5, evaluate('2 + 3')
assert_eq 0, evaluate('0 * 1 + 1')
assert_eq 1, evaluate('(0 * 1) + 1')
assert_eq 1, evaluate('(0 * 1) + 1 * ((0 * 1) + 1)')
assert_eq 465, evaluate('3 * 1 + ((2 * 4 + 3) * (2 * 4) + 3)')
assert_eq 7650, evaluate('1 * 2 * (4 + 5 + 6) * (7 + 8) * (9 + 8) ')

assert_eq 10, evaluate('2 * 3 + 2')
assert_eq 231, evaluate('1 + 2 * 3 + 4 * 5 + 6')
assert_eq 46, evaluate('2 * 3 + (4 * 5)')
assert_eq 51, evaluate('1 + (2 * 3) + (4 * (5 + 6))')
assert_eq 1445, evaluate('5 + (8 * 3 + 9 + 3 * 4 * 3)')
assert_eq 669060, evaluate('5 * 9 * (7 * 3 * 3 + 9 * 3 + (4 * 8 + 6))')
assert_eq 23340, evaluate('((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2')

assert_eq 47305787760, evaluate('7 * 4 * (6 + 3 + 2 * 9 + (7 * 5 + 4 * 5 * 9)) * (8 * (2 + 7 * 5) * 6 * 5 * 5) + 5')

res18 = File.readlines('day18.txt').map { |l| evaluate(l)}.sum

puts 'YOUPI !!!'
puts res18
`git add . && git commit -am 'green au  tocommit'`