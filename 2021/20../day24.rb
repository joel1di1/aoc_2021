# frozen_string_literal: true

require_relative '../../fwk'

class Alu
  def initialize() end

  def display(msg, w, x, y, z)
    puts "#{msg}: #{[w, x, y, z].join(',')}"
  end

  def inp(_a = nil)
    @monad_input.shift
  end

  def mul(a, b)
    a * b
  end

  def add(a, b)
    a + b
  end

  def div(a, b)
    a / b
  end

  def mod(a, b)
    a % b
  end

  def eql(a, b)
    a == b ? 1 : 0
  end

  def valid?(monad_input)
    # puts "process: #{monad_input}"
    @monad_input = monad_input.chars.map(&:to_i)
    legacy
  end

  def legacy
    z = block(inp, 0, 1, 13, 5)
    z = block(inp, z, 1, 15, 14)
    z = block(inp, z, 1, 15, 15)
    z = block(inp, z, 1, 11, 16)
    z = block(inp, z, 26, -16, 8)
    z = block(inp, z, 26, -11, 9)
    z = block(inp, z, 26, -6, 2)
    z = block(inp, z, 1, 11, 13)
    z = block(inp, z, 1, 10, 16)
    z = block(inp, z, 26, -10, 6)
    z = block(inp, z, 26, -8, 6)
    z = block(inp, z, 26, -11, 9)
    z = block(inp, z, 1, 12, 11)
    z = block(inp, z, 26, -15, 5)
    z
  end

  def block(w, z, a1, a2, a3)
    x = z
    x = mod x, 26
    z = div z, a1
    x = add x, a2
    x = eql x, w
    x = eql x, 0
    y = 25
    y = mul y, x
    y = add y, 1
    z = mul z, y
    y = mul y, 0
    y = add y, w
    y = add y, a3
    y = mul y, x
    z = add z, y
    z
  end
end

alu = Alu.new
assert_eq 2064736350, alu.valid?('13579246899999')
alu.valid?('99999999999999')
alu.valid?('88888888888888')
puts "test OKs!"

#
# (11..99).to_a.find do |num|
#   nums = num.to_s
#   next if nums.include?('0')
#
#   res = alu.valid?(nums)
#   puts "num: #{num}, res: #{res}"
#   raise "sol: #{num}" if res == 0
# end
