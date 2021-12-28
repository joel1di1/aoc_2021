# frozen_string_literal: true

require_relative '../../fwk'

class Alu
  def initialize() end

  def display(msg, w, x, y, z)
    puts "#{msg}: #{[w, x, y, z].join(',')}"
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
    input = @monad_input.dup

    z = block(input.shift, 0, 1, 13, 5)
    z = block(input.shift, z, 1, 15, 14)
    z = block(input.shift, z, 1, 15, 15)
    z = block(input.shift, z, 1, 11, 16)
    z = block(input.shift, z, 26, -16, 8)
    z = block(input.shift, z, 26, -11, 9)
    z = block(input.shift, z, 26, -6, 2)
    z = block(input.shift, z, 1, 11, 13)
    z = block(input.shift, z, 1, 10, 16)
    z = block(input.shift, z, 26, -10, 6)
    z = block(input.shift, z, 26, -8, 6)
    z = block(input.shift, z, 26, -11, 9)
    z = block(input.shift, z, 1, 12, 11)
    z = block(input.shift, z, 26, -15, 5)
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

  def humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours], [Float::INFINITY, :days]].map { |count, name|
      if secs > 0
        secs, n = secs.divmod(count)

        "#{n.to_i} #{name}" unless n.to_i == 0
      end
    }.compact.reverse.join(' ')
  end

  def find
    array = [[1, 13, 5],
             [1, 15, 14],
             [1, 15, 15],
             [1, 11, 16],
             [26, -16, 8],
             [26, -11, 9],
             [26, -6, 2],
             [1, 11, 13],
             [1, 10, 16],
             [26, -10, 6],
             [26, -8, 6],
             [26, -11, 9],
             [1, 12, 11],
             [26, -15, 5],]

    zs_to_inputs = { 0 => '' }
    array.each do |line|
      count = zs_to_inputs.count
      puts "compute #{line}, #{count} sols"
      t_start = Time.now
      zs_to_inputs = zs_to_inputs.map do |previous_z, computed_input|
        (1..9).map do |new_num|
          z = block(new_num, previous_z, *line)
          { z => (computed_input + new_num.to_s) }
        end
      end.flatten.uniq
      new_zs_by_max_inputs = {}
      zs_to_inputs.map(&:first).each do |z, computed_input|
        new_zs_by_max_inputs[z] = computed_input if z < 1_000_000 && computed_input > (new_zs_by_max_inputs[z] || '0')
      end
      zs_to_inputs = new_zs_by_max_inputs
      t_end = Time.now
      elapsed = t_end - t_start
      puts "\tcomputed #{line} in #{elapsed}, next estimated: #{humanize((elapsed/count) * zs_to_inputs.count)}"
    end

    puts zs_to_inputs.select { |k, v| k == 0 }
  end

end

alu = Alu.new
assert_eq 2064736350, alu.valid?('13579246899999')
alu.valid?('99999999999999')
alu.valid?('88888888888888')
puts "test OKs!"

alu.find

#
# (11..99).to_a.find do |num|
#   nums = num.to_s
#   next if nums.include?('0')
#
#   res = alu.valid?(nums)
#   puts "num: #{num}, res: #{res}"
#   raise "sol: #{num}" if res == 0
# end
