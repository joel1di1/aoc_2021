# frozen_string_literal: true

require 'readline'

def read_passports(file)
  content = File.read(file)
  content.split("\n\n").map { |group| group.split.map { |e| e.split(':') }.to_h }
end

def invalid_date(value, min, max)
  !value[/^\d{4}$/] || value.to_i < min || value.to_i > max
end

def invalid_hgt(hgt)
  return true unless hgt[/^\d+(cm|in)$/]
  return true if hgt[/^\d+cm$/] && (hgt.to_i < 150 || hgt.to_i > 193)
  return true if hgt[/^\d+in$/] && (hgt.to_i < 59 || hgt.to_i > 76)
end

def valid?(passport)
  passport.delete 'cid'
  return false if passport.size != 7

  return false if invalid_date(passport['byr'], 1920, 2002)
  return false if invalid_date(passport['iyr'], 2010, 2020)
  return false if invalid_date(passport['eyr'], 2020, 2030)
  return false if invalid_hgt(passport['hgt'])
  return false unless passport['hcl'][/^#(\d|[a-f]){6}$/]
  return false unless %w[amb blu brn gry grn hzl oth].include?(passport['ecl'])
  return false unless passport['pid'][/^\d{9}$/]

  true
end

def count_valid(passports)
  passports.select { |passport| valid?(passport) }.count
end

def process(file)
  puts "#{file}: #{count_valid(read_passports(file))}"
end

process('day4_sample.txt')
process('day4.txt')
