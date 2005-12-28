#!/usr/bin/ruby -w

# Licensed under GPL-2 or later
# Author: Petteri Räty <betelgeuse@gentoo.org>

$: << File.dirname(__FILE__)
require "pkgutil.rb"

elf = ARGV[0]

if ! elf || ! is_elf(elf)
	$stderr.puts 'This program takes one arguments that should be an elf file.'
	exit 1
end

run_scanelf(elf) do | lib |
	puts lib
	puts "\t" + get_pkg_of_lib(lib)
end