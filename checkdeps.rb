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
	puts
	puts 'Everything else is passed to qfile as it is'
	exit(exit_value)
end

ARGV.each do | arg | 
	if arg =~ /^(-v|--verbose)$/
		$verbose = true
	elsif arg =~ /^(-h|--help)$/
		print_help(0)
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
	`qfile -qC #{lib}`.chomp
end

def handle_lib(pkgs,libs,obj,lib)
	if ! libs.index(lib)
		if File.exists?(lib)
			libs << lib
			pkg = get_pkg_of_lib(lib)
			puts pkg if $DEBUG
			pkgs << pkg
			return true
		else
			$stderr.print "Parsed #{lib} from the output of ldd"
			$stderr.puts  'but no such file exists'
			return false
		end
	end
end

def eval_line(pkgs,libs,obj,line)
	puts line if $DEBUG
	start = line.index('>')
	puts "start ",start if $DEBUG
	if start
		start+=1
		stop  = line.index('(',start)
		puts "stop ",stop if $DEBUG
		if stop
			stop-=1
			lib = line[start..stop]
			lib.strip!

			puts lib if $DEBUG

			if( lib != '' )
				handle_lib(pkgs, libs,obj,lib)
			end
		end
	end
end

lib_table =[]
pkg_table =[]

qlist = IO.popen("qlist #{pkgs_to_check.join(' ')}")

while obj = qlist.gets
	obj.rstrip!
	if isElf(obj)
		ldd = IO.popen("ldd #{obj}")
		ldd.each do | line | eval_line(pkg_table,lib_table,obj,line) end
	end
end

qlist.close

if $? != 0
	$stderr.puts("qlist did not run succesfully.")
	$stderr.puts("Please emerge portage-utils if you don't already have it.")
end

puts pkg_table.sort.uniq

if $verbose
	puts lib_table
end
