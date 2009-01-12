#!/usr/bin/ruby

$: << File.dirname(__FILE__)
require "changelog.rb"

system("check-changelog ChangeLog")
puts "Exit status: " + $?.to_s
$? != 0 && exit

system("adjutrix -k --log-level silent")
system("cvs diff")
puts "Exit status: " + $?.to_s
$? == 2 && exit

system('FEATURES="-strict" repoman -d full')
puts "Exit status: " + $?.to_s
$? != 0 && exit

system("qualudis --log-level silent")
puts "Exit status: " + $?.to_s

system("pcheck -r portdir")
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
