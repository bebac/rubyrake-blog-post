require 'rake'
require 'rake/tasklib'
require 'rake/clean'
require 'open3'
require 'pstore'

module Rake
  
  module C

    module Dep

      extend self

      def filename
        'rakelib/.depends'
      end

      def store
        @@store ||= PStore.new(filename)
      end

    end

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
          task object => [ source ] + (Dep.store.transaction(true) { |store| store[object] } || []) do |t|
            unless uptodate?(t.name, t.prerequisites)
              
              command = "cl /nologo /showIncludes /Fo#{t.name} /c #{t.prerequisites[0]}"
              autodepends = []

              puts command
              
              Open3.popen2e(command) do |stdin, stdout, wait_thr|
                stdin.close
                stdout.lines do |line|
                  case line
                  when /^Note:\s+including file:/
                    autodepends << line.sub(/^Note:\s+including file:/, '').strip
                  else
                    puts line
                  end
                end
                fail "error compiling #{t.prerequisites[0]}" unless wait_thr.value == 0
              end
              
              Dep.store.transaction(false) { |store| store[object] = autodepends }

            end
          end
        end

        executable = "%s.exe" % [ name ]

        task executable => objects do |t|            
          unless uptodate?(t.name, t.prerequisites)
            sh "link /NOLOGO /OUT:#{t.name} #{t.prerequisites.join(' ')}"
          end
        end    
        task name => executable

        CLEAN.include(objects, Dep.filename)
        CLOBBER.include(executable)

      end

    end

  end

end
