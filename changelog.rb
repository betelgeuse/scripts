def getLastChangeLogEntry()

	f = File.new('ChangeLog')
	entry=''

	user = ENV['ECHANGELOG_USER']

	if ! user
		$stderr.puts('Need ECHANGELOG_USER env variable.')
		$stderr.puts('See man echangelog.')
		exit 1
	end

	puts user

   	while line = f.gets
      	if(line.match(user))

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
	return entry.rstrip.gsub('"','\"')
end
