# frozen_string_literal: true

require 'digest'

secret_key = 'ckczppom'
i = 0
loop do
  i += 1
  # puts "i: #{i}, key: #{secret_key + i.to_s}, md5: #{Digest::MD5.hexdigest(secret_key + i.to_s)}"
  break if Digest::MD5.hexdigest(secret_key + i.to_s).start_with?('000000')
end
puts "part1: secret_key: #{secret_key}, i: #{i}"
