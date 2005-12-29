# Licensed under GPL-2 or later
# Author: Petteri Räty <betelgeuse@gentoo.org>

MAGIC="\x7FELF"
def is_elf(file)
	if ! File.executable?(file) || ! File.file?(file)
		puts "#{file} is not executable or a normal file" if $verbose
		return false
	end

	return File.read(file, 4) == MAGIC
end

def get_pkg_of_lib(lib)
	command="qfile -qC #{lib}"
	output = `#{command}`.chomp

	if $? != 0
		$stderr.puts "#{command} returned a non zero value."
		return nil
	end

	puts command + ' :' + output if $DEBUG

	output = output.split("\n").uniq.join(' || ')

	puts 'Formatted: ' + output if $DEBUG

	output
end

def handle_extra_output(prog)
	$stderr.puts 'This program expects only one line'
	$stderr.puts 'of output from scanelf. Extra lines:'
	while line = scanelf.gets
		$stderr.puts line
	end
	exit 2
end

def run_scanelf(elf)
	scanelf = IO.popen("scanelf -q -F '%n#F' #{elf}")
	first_line = scanelf.gets
	handle_extra_output(scanelf) if not scanelf.eof?
	scanelf.close

	libs = first_line.split(',')
	for lib in libs
		yield lib
	end	
end

class ScanElf
	private_class_method :new
	@@instance = nil
	
	def ScanElf.instance
		@@instance = new unless @@instance
		@@instance
	end

	def initialize
		@process = IO.popen('scanelf -q -F "%n#F" -f /dev/stdin','r+')
	end

	def each(elf, &block)
		@process.puts(elf)
		result = @process.gets
	
		libs = result.split(',')
		for lib in libs
			block.call(lib)
		end
	end
end
	