require 'rake'
require 'rake/tasklib'
require 'open3'

module Rake
  
  module C

    class ExecutableTask < TaskLib

      attr_accessor :name
      attr_accessor :sources
  
      def initialize(name)
        init(name)
        if block_given?
          yield self
          define
        end
      end

      def init(name)
        @name = name
        @sources = FileList.new
      end

      def define

        objects = sources.collect { |s| s.sub(/\.c$/, '.o') }

        sources.zip(objects) do |source, object|
          task object => [ source ] do |t|
            unless uptodate?(t.name, t.prerequisites)
              
              command = "gcc -H -o#{t.name} -c #{t.prerequisites[0]}"
              autodepends = []

              puts command
              
              Open3.popen2e(command) do |stdin, stdout, wait_thr|
                stdin.close
                stdout.lines do |line|
                  case line
                  when /^\./
                    autodepends << line.sub(/^\.+\s+/, '').strip
                  when /Multiple include guards/
                    # Filter out include guards warnings.
                    stdout.lines do |line|                        
                        if line =~ /:$/ then puts line; break; end
                    end
                  else
                    puts line
                  end
                end
                fail "error compiling #{t.prerequisites[0]}" unless wait_thr.value == 0
              end

            end
          end
        end

        executable = "%s" % [ name ]

        task executable => objects do |t|
          unless uptodate?(t.name, t.prerequisites)
            sh "gcc -o#{t.name} #{t.prerequisites.join(' ')}"
          end
        end

      end

    end

  end

end
