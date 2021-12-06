# frozen_string_literal: true

require 'readline'

def read_passports(file)
  content = File.read(file)
  content.split("\n\n").map { |group| group.split.map { |e| e.split(':') }.to_h }
end

def valid?(passport)
  return true if passport.size == 8
  return true if passport.size == 7 && passport['cid'].nil?

  false
end

def count_valid(passports)
  passports.select { |passport| valid?(passport) }.count
end

def process(file)
  puts "#{file}: #{count_valid(read_passports(file))}"
end

process('day4_sample.txt')
process('day4.txt')

