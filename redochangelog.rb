#!/usr/bin/ruby

$: << File.dirname(__FILE__)
require "changelog.rb"
require "fileutils"

entry = getLastChangeLogEntry()
puts entry
FileUtils.mv 'ChangeLog', '/tmp/ChangeLog.bak' || exit

system("cvs up")

system("echangelog " + "'" + entry + "'")
puts "Delete ChangeLog.bak?"
FileUtils.rm '/tmp/ChangeLog.bak' if $stdin.gets.match(/y/)
