# frozen_string_literal: true

require_relative '../../fwk'


def evaluate(str)
  eval(str)
end

assert_eq 6, evaluate('2 * 3')
assert_eq 5, evaluate('2 + 3')

`git add . && git commit -am 'green autocommit'`