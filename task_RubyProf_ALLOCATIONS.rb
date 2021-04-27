require_relative 'task-2.rb'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work(filename = 'data_2000.txt', disable_gc: false)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat_ALLOC.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
