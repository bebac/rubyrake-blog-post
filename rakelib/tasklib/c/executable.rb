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
        task name do
        end
      end

    end

  end

end
