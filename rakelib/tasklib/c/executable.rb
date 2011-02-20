require 'rake'
require 'rake/tasklib'

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
              sh "gcc -o#{t.name} -c #{t.prerequisites[0]}"
            end
          end
        end

        executable = "%s" % [ name ]

        task executable => objects do |t|
          sh "gcc -o#{t.name} #{t.prerequisites.join(' ')}"
        end
      end

    end

  end

end
