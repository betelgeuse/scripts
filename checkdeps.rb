#!/usr/bin/ruby -w

# Licensed under GPL-2 or later
# Author: Petteri Räty <betelgeuse@gentoo.org>

$verbose = false

pkgs_to_check=[]

def print_help(exit_value)
	puts 'Usage: checkdeps.rb opts|pkgs'
	puts
	puts 'Options:'
	puts '-v, --verbose'
	puts '-h, --help'
	puts '-d, --debug'
	puts
	puts 'Everything else is passed to qfile as it is'
	exit(exit_value)
end

ARGV.each do | arg | 
	if arg =~ /^(-v|--verbose)$/
		$verbose = true
	elsif arg =~ /^(-h|--help)$/
		print_help(0)
	elsif arg =~ /^(-d|--debug)$/
		$DEBUG = true
	else
		pkgs_to_check << arg
	end
end

pkgs_to_check.length == 0 && print_help(1)

MAGIC="\x7FELF"

def isElf(file)
	if ! File.executable?(file) || ! File.file?(file)
		puts "#{file} is not executable or a normal file" if $verbose
		return false
	end

	return File.read(file, 4) == MAGIC
end

def get_pkg_of_lib(lib)
	command="qfile -qC #{lib}"
	output = `#{command}`.chomp
	puts "qfile -qC :" + output if $DEBUG
	output = output.split("\n").uniq.join(' || ')
	puts "Formatted: " + output if $DEBUG
	if $? != 0
		$stderr.puts "#{command} returned a non zero value."
	end
	output
end

def handle_lib(pkgs,libs,obj,lib)
	if ! libs.index(lib)
		puts "library: " + lib if $DEBUG
		libs << lib
		pkg = get_pkg_of_lib(lib)
		pkgs << pkg if ! pkgs.index(pkg)
	end
end

def parse_output(pkg_table,lib_table,obj,line)
	puts "scanelf: " + line if $DEBUG
	libs = line.split(',')
	for lib in libs
		handle_lib(pkg_table,lib_table,obj,lib)
	end
	
end

def handle_extra_output(prog)
	$stderr.puts 'This program expects only one line'
	$stderr.puts "of output from scanelf. Extra lines:"
	while line = scanelf.gets
		$stderr.puts line
	end
	exit 2
end

lib_table =[]
pkg_table =[]

qlist = IO.popen("qlist #{pkgs_to_check.join(' ')}")

while obj = qlist.gets
	obj.rstrip!
	if isElf(obj)
		puts "obj: " + obj if $DEBUG
		scanelf = IO.popen("scanelf -q -F '%n#F' #{obj}")
		first_line = scanelf.gets
		parse_output(pkg_table,lib_table,obj, first_line)
		handle_extra_output(scanelf) if not scanelf.eof?
	end
end

qlist.close

if $? != 0
	$stderr.puts("qlist did not run succesfully.")
	$stderr.puts("Please emerge portage-utils if you don't already have it.")
end

puts pkg_table.sort

if $verbose
	puts lib_table
end
