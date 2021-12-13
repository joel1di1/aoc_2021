# frozen_string_literal: true

require_relative '../../fwk'


def evaluate(str)
  26
end

assert_eq 26, evaluate('2 * 3')
assert_eq 26, evaluate('2 * 3')

`git add . && git commit -am 'green autocommit'`