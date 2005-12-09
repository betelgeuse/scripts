#!/usr/bin/ruby

require "/home/betelgeuse/bin/changelog.rb"

system("eshowkw")
system("cvs diff")
puts "Exit status: " + $?.to_s
$? == 2 && exit

system("repoman full")
puts "Exit status: " + $?.to_s
$? != 0 && exit

entry = ARGV[0]
entry || entry = getLastChangeLogEntry

puts entry
puts 'Continue?'

if $stdin.gets.match(/y|yes/i)
	system("repoman commit --commitmsg '#{entry}'")
end
