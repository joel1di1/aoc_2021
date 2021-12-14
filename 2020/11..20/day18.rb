# frozen_string_literal: true

require_relative '../../fwk'

def evaluate(str)
  str = str.gsub(/\s/, '')
  while match = str.scan(/(\(([^()]+)\))/)[0]
    str = str.gsub(match[0], evaluate(match[1]).to_s)
  end

  while str[/^((\d+)[+*](\d+))[+*]/]
    expr = Regexp.last_match[1]
    res = eval(expr)
    str = str.gsub(/^((\d+)[+*](\d+))/, res.to_s)
  end
  eval(str)
end

assert_eq 6, evaluate('2 * 3')
assert_eq 5, evaluate('2 + 3')
assert_eq 10, evaluate('2 + 3 * 2')
assert_eq 71, evaluate('1 + 2 * 3 + 4 * 5 + 6')
assert_eq 26, evaluate('2 * 3 + (4 * 5)')
assert_eq 49, evaluate('3 + (4 * 5) * 2 + 3')
assert_eq 12240, evaluate('5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))')
assert_eq 13632, evaluate('((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2')

`git add . && git commit -am 'green autocommit'`