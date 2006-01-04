def getLastChangeLogEntry()

	f = File.new('ChangeLog')
	entry=''

   	while line = f.gets
      	if(line.match(/betelgeuse@gentoo.org/))

           	while ! line.match(/:$/)
               	line = f.gets
           	end

           	while (line = f.gets) && line.strip != ''
                entry += line.strip + ' '
           	end

            break
   	    end
   	end

	f.close
	return entry.rstrip
end
