# frozen_string_literal: true

require_relative '../../fwk'

def evaluate(str)
  str = str.gsub(/\s/, '')
  while match = str.scan(/(\(([^()]+)\))/)[0]
    str = str.gsub(match[0], evaluate(match[1]).to_s)
  end

  while match = str.scan(/(\d+[+]\d+)/)[0]
    str = str.gsub(match[0], eval(match[0]).to_s)
  end

  eval(str)
end
#
# assert_eq 6, evaluate('2 * 3')
# assert_eq 5, evaluate('2 + 3')
# assert_eq 0, evaluate('0 * 1 + 1')
# assert_eq 1, evaluate('(0 * 1) + 1')
# assert_eq 1, evaluate('(0 * 1) + 1 * ((0 * 1) + 1)')
#
# assert_eq 465, evaluate('3 * 1 + ((2 * 4 + 3) * (2 * 4) + 3)')

assert_eq 7650, evaluate('1 * 2 * (4 + 5 + 6) * (7 + 8) * (9 + 8) ')



assert_eq 10, evaluate('2 + 3 * 2')
assert_eq 231, evaluate('1 + 2 * 3 + 4 * 5 + 6')
assert_eq 46, evaluate('2 * 3 + (4 * 5)')
assert_eq 1445, evaluate('5 + (8 * 3 + 9 + 3 * 4 * 3)')
assert_eq 669060, evaluate('5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))')
assert_eq 23340, evaluate('((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2')

puts File.readlines('day18.txt').map{|l| evaluate(l)}.sum

puts 'YOUPI !!!'
`git add . && git commit -am 'green autocommit'`