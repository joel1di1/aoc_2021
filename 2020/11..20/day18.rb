# frozen_string_literal: true

require_relative '../../fwk'


def evaluate(str)
  str = str.gsub(/\s/,'')
  while str[/^((\d+)[+*](\d+))[+*]/]
    expr = Regexp.last_match[1]
    res = eval(expr)
    str = str.gsub(/^((\d+)[+*](\d+))/, res.to_s)
  end
  eval(str)
end

# assert_eq 6, evaluate('2 * 3')
# assert_eq 5, evaluate('2 + 3')
# assert_eq 10, evaluate('2 + 3 * 2')
assert_eq 71, evaluate('1 + 2 * 3 + 4 * 5 + 6')

`git add . && git commit -am 'green autocommit'`