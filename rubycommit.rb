#!/usr/bin/ruby

$: << File.dirname(__FILE__)
require "changelog.rb"

system("adjutrix -k --log-level silent")
system("cvs diff")
puts "Exit status: " + $?.to_s
$? == 2 && exit

system('FEATURES="-strict" repoman full')
puts "Exit status: " + $?.to_s
$? != 0 && exit

system("qualudis")
puts "Exit status: " + $?.to_s

entry = ARGV[0]
entry || entry = getLastChangeLogEntry

puts entry
puts 'Repoman arg: "' + entry + '"'
puts 'Continue?'

if $stdin.gets.match(/y|yes/i)
	puts "repoman commit --commitmsg \"#{entry}\"" if $DEBUG
	system("repoman commit --commitmsg \"#{entry}\"")
end
