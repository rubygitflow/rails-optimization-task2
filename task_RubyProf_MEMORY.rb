require_relative 'task-2.rb'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(filename = 'data_2000.txt', disable_gc: false)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')
