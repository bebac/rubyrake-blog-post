require 'rake'

require File.dirname(__FILE__) + '/rakelib/tasklib/c/executable'

Rake::C::ExecutableTask.new :app do |executable|
    executable.sources.add("source/*.c")
end

task :default => :app
