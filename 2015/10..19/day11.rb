# frozen_string_literal: true

require 'byebug'
password = 'vzbxkghb'

def contain_following_chrs(str)
  values = str.chars.map(&:ord)
  adjs = []
  values.each_with_index do |value, i|
    adjs << if i.zero?
              1
            elsif value == values[i - 1] + 1
              adjs.last + 1
            else
              1
            end
    return true if adjs.last >= 3
  end
  false
end

def valid?(password)
  return false if password[/[iol]/]
  return false unless contain_following_chrs(password)
  return false unless password[/(\w)\1.*(\w)\2/]

  true
end

# increment string by one letter
def increment(str)
  chars = str.reverse.chars
  inc = 1
  index = 0
  while inc.positive?
    c = chars[index].ord + inc
    if c > 'z'.ord
      chars[index] = 'a'
      index += 1
    else
      chars[index] = c.chr
      inc = 0
    end
  end

  chars.reverse.join
end

def next_password(password)
  password = increment(password)
  password = increment(password) until valid?(password)
  password
end

password = 'vzbxkghb'

password = next_password(password)
puts password
password = next_password(password)
puts password
