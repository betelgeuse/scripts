#!/usr/bin/ruby -w

$verbose = false
$debug = false

pkgs_to_check=[]

def print_help(exit_value)
	puts 'Usage: checkdeps.rb opts|pkgs'
	puts
	puts 'Options:'
	puts '-v, --verbose'
	puts '-d, --debug'
	puts '-h, --help'
	puts
	puts 'Everything else is passed to qfile as it is'
	exit(exit_value)
end

ARGV.length == 0 && print_help(1)

ARGV.each do | arg | 
	if arg =~ /-v|--verbose/
		$verbose = true
	elsif arg =~ /-d|--debug/
		$debug = true
	elsif arg =~ /-h|--help/
		print_help(0)
	else
		pkgs_to_check << arg
	end
end

MAGIC=[127,69,76,70]

def isElf(file)
	if ! File.executable?(file) || ! File.file?(file)
		if $verbose
			puts "#{file} is not executable or a normal file"
		end
		return false
	end

	f = File.new(file)
	i = 0
	match=true
	
	while ( c = f.getc ) && i < 4
		if c != MAGIC[i]
			match=false
		end
		i=i+1
	end

	f.close

	return match
end

def get_pkg_of_lib(lib)
	`qfile -qC #{lib}`.chomp
end

def handle_lib(pkgs,libs,obj,lib)
	if ! libs.index(lib)
		if File.exists?(lib)
			libs << lib
			pkg = get_pkg_of_lib(lib)
			puts pkg if $debug
			pkgs << pkg
			return true
		else
			$stderr.print "Parsed #{lib} from the output of ldd"
			$stderr.puts  "but no such file exists"
			return false
		end
	end
end

def eval_line(pkgs,libs,obj,line)
	puts line if $debug
	start = line.index('>')
	puts "start",start if $debug
	if start
		start+=1
		stop  = line.index('(',start)
		puts "stop",stop if $debug
		if stop
			stop-=1
			lib = line[start..stop]
			lib.strip!

			puts lib if $debug

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

if $debug
	require 'pp'
	pp pkgs
end

puts pkg_table.sort.uniq