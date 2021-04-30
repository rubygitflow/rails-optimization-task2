require_relative 'task-2.rb'
require 'memory_profiler'

report = MemoryProfiler.report do
  work(filename = 'data_2000.txt', disable_gc: false)
end
report.pretty_print(scale_bytes: true)

