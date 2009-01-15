##########################
# Tasks to help with svn #
##########################
require 'readline'

namespace :svn do
  # I load stories twice to ensure that story purging is effective.
  desc "Check to ensure a clean commit"
  task :check => [
    "db:drop", "db:create", "db:migrate",
    "db:stories", "db:stories", "test:all"
  ] do
    if (unadded = `svn st | grep ^?`).size > 0
      $stderr.write "\nThe following files have not been committed to SVN:\n"
      $stderr.write unadded
      $stderr.write "Ensure that the proper svn:ignore flags have been set up\n"
      $stderr.write "and that you are not forgetting to commit any files\n\n"
      $stderr.flush
      return false
    end   
  end

  desc "Adds all \"?\" SVN files to SVN"
  task :add do
    files = `svn st | grep ^? | sed s/?\\s*//`.split
    if files.size > 0
      files.each do |file|
        puts "adding #{file}"
        `svn add #{file}`
      end
    else
      $stdout.write "No files to add\n"; $stdout.flush
    end
  end
  
  desc "Interactive svn ignore property setting" 
  task :ignore do
    files = `svn st | grep ^? | awk '{print $2}'`.split
    if files.size > 0
      count = files.size
      n = 1
      # group files by directory
      groups = {}
      files.each do |f|
        dir, file = File.split(f)
        if groups.include? dir
          groups[dir] << file
        else
          groups[dir] = [file]
        end
      end
      quit = false
      groups.each_pair do |dir, fs|
        for file in fs
          puts "[#{n} of #{count}] Ignore #{File.directory?(File.join(dir, fs)) ? "directory" : "file"} #{File.join(dir, file)}? (y/N/q)"
          line = Readline::readline '> '
          if line.downcase.strip == 'y'
            puts "IGNORING"
            `svn propset svn:ignore #{file} #{dir}`
          elsif line.downcase.strip == 'q'
            quit = true
            break
          end
          n += 1
          puts
        end
        break if quit
      end
    else
      $stdout.write "No files to ignore\n"; $stdout.flush
    end
  end

end

