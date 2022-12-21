require 'byebug'

$iter = 0

File.readlines('day21.txt').map do |line|
  eval(line)
end

puts "part 1: #{@root.call}"

@root = -> { @wvvv.call == @whqc.call  }

@monkeys = {}
File.readlines('day21_part2.txt').map do |line|
  name, expr = line.strip.split("=")
  expr = expr.strip
  val = nil
  case expr
  when /\d+/
    val = expr.to_i
  when /(\w+) (.)\ (\w+)/
    val = [$1, $2, $3]
  else
    raise "unknown expr: #{expr}"
  end
  @monkeys[name.strip] = val
end

@monkeys['humn'] = 'x'

def produce_calcul_string(name)
  val = @monkeys[name]
  case val
  when Integer
    val
  when Array
    left = produce_calcul_string(val[0])
    right = produce_calcul_string(val[2])
    if left.is_a?(Integer) && right.is_a?(Integer)
      left.send(val[1], right)
    else
      "(#{left} #{val[1]} #{right})"
    end
  when String
    val
  else
    debugger
    raise "unknown val: `#{val}` for name: #{name}"
  end
end

str_wvvv = produce_calcul_string('wvvv')
str_whqc = produce_calcul_string('whqc')

# puts "\n=================\npart2: "
# puts "#{str_whqc} = #{str_wvvv}"

whqc = str_whqc.to_i

while str_wvvv != 'x'
  operator = nil
  other = nil
  case str_wvvv
  when /^\((.*)\s(\S)\s(\d+)\)$/
    capts = str_wvvv.match(/^\((.*)\s(\S)\s(\d+)\)$/).captures
    str_wvvv = capts[0]
    operator = capts[1]
    other = capts[2].to_i

    case operator
    when '+'
      whqc -= other.to_i
    when '-'
      whqc += other.to_i
    when '*'
      whqc /= other.to_i
    when '/'
      whqc *= other.to_i
    else
      raise "unknown operator: #{capts[1]}"
    end
  when /^\((\d+)\s(\S)\s(.*)\)$/
    capts = str_wvvv.match(/^\((\d+)\s(\S)\s(.*)\)$/).captures
    str_wvvv = capts[2]
    operator = capts[1]
    other = capts[0].to_i

    case operator
    when '+'
      whqc -= other.to_i
    when '-' #a = b - x  =>  x = b - a
      whqc = other.to_i - whqc
    when '*' #a = b * x  =>  x = b / a
      whqc /= other.to_i
    when '/' #a = b / x  =>  x = b * a
      whqc = other / whqc
    else
      raise "unknown operator: #{capts[1]}"
    end

  else
    debugger
    raise "unknown str_wvvv: #{str_wvvv}"
  end

end

puts "part2: #{whqc}"
