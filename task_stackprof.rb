require_relative 'task-2.rb'
require 'stackprof'

RubyProf.measure_mode = RubyProf::MEMORY

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work(filename = 'data_2000.txt', disable_gc: false)
end
