#!/usr/bin/ruby -w

# Licensed under GPL-2 or later
# Author: Petteri Räty <betelgeuse@gentoo.org>

$: << File.dirname(__FILE__)
require "pkgutil.rb"

$verbose = false
$quiet   = false

pkgs_to_check=[]

def print_help(exit_value)
	puts 'Usage: checkdeps.rb opts|pkgs'
	puts
	puts 'Options:'
	puts '-q, --quiet'
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
	elsif arg =~ /^(-q|--quiet)$/
		$quiet = true
	elsif arg =~ /^(-d|--debug)$/
		$DEBUG = true
		$verbose = true
	else
		pkgs_to_check << arg
	end
end

pkgs_to_check.length == 0 && print_help(1)

class ElfObj
	attr_reader :path, :pkgs

	def initialize(path)
		@path = path
		@pkgs = []
	end
	
	def <<(pkg)
		if ! @pkgs.index(pkg)
			@pkgs << pkg
		else
			nil
		end
	end

	def <=>(r)
		return @path <=> r.path
	end

	def to_s()
		puts 'ElfObj to_s:' if $DEBUG
		s = "\t" + @path
		s+="\t" + @path + "\n\t\t" + @pkgs.sort.join("\n\t\t") if $DEBUG
		s
	end
end


def handle_new_lib(obj,lib)
	puts 'library: ' + lib if $DEBUG
	$lib_table << lib
	pkg = get_pkg_of_lib(lib)
	
	if ! pkg
		return
	end

	if obj_table = $pkg_hash[pkg]
		obj_table << obj
	else
		$pkg_hash[pkg]=[obj]
		obj << pkg
	end
end

$lib_table =[]
$pkg_hash ={}

qlist = IO.popen("qlist #{pkgs_to_check.join(' ')}")

while obj = qlist.gets
	obj.rstrip!
	if is_elf(obj)
		puts 'obj: ' + obj if $DEBUG
		elf_obj = ElfObj.new(obj)
		run_scanelf(obj) do | lib |
			if ! $lib_table.index(lib)
				handle_new_lib(elf_obj,lib)
			end
		end
	end
end

qlist.close

if $? != 0
	$stderr.puts('qlist did not run succesfully.')
	$stderr.puts('Please emerge portage-utils if you don\'t already have it.')
end

require 'pp' if $DEBUG

$pkg_hash.sort.each do | pair |
	puts 'Key: ' if $DEBUG
	puts pair[0]
	puts 'Value: ' if $DEBUG
	puts pair[1].uniq.sort if ! $quiet
	puts 'end Hash.' if $DEBUG
end

if $verbose
	puts $lib_table
end
