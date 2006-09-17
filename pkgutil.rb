# Licensed under GPL-2 or later
# Author: Petteri Räty <betelgeuse@gentoo.org>

MAGIC="\x7FELF"

# It seems that at least qt has shared libraries that aren't
# executable
def is_elf(file)
	File.executable?(file) && File.file?(file) && File.read(file, 4) == MAGIC
end

def get_pkg_of_lib(lib)
	command='qfile -vqC ' + lib
	output = `#{command}`.split("\n")
	output.uniq!
	raise "#{command} exited with #{$?}" if $? != 0 
	output.join(' || ')
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
		@process = IO.popen('scanelf -B -F "%n#F" -f /dev/stdin','r+')
	end

	def each(elf)
		@process.puts(elf)

		@process.gets.scan(/[^,\s]+/) { |match|
		    yield match
		}
	end
end

