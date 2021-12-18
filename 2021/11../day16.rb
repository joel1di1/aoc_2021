# frozen_string_literal: true

require_relative '../../fwk'

class Message

  def initialize(str)
    @str = str
  end
end

def next_paquet(msg)
  version = msg.shift(3)
  {version: version.join}
end

def decode(msg)
  packet = next_paquet(msg)
  puts packet
end



content = File.read('day16.txt').chars.map {|c| c.hex.to_s(2).ljust(4, '0')}.join.chars.map(&:to_i)

decode content
puts content.join