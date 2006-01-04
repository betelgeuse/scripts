#!/usr/bin/ruby

$: << File.dirname(__FILE__)
require "changelog.rb"

system("eshowkw")
system("cvs diff")
puts "Exit status: " + $?.to_s
$? == 2 && exit

system("repoman full")
puts "Exit status: " + $?.to_s
$? != 0 && exit

entry = ARGV[0]
entry || entry = getLastChangeLogEntry

subbed = entry.gsub("'") { "\\'" }

puts entry
puts "Repoman arg: '" + subbed + "'"
puts 'Continue?'

if $stdin.gets.match(/y|yes/i)
	puts "repoman commit --commitmsg '#{subbed}'" if $DEBUG
	system("repoman commit --commitmsg '#{subbed}'")
end
