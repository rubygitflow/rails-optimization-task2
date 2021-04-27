require_relative 'task-2.rb'
require 'benchmark'

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

puts "rss at start: #{print_memory_usage}"

time = Benchmark.realtime do
  work(filename = 'data_32000.txt', disable_gc: true)
end

puts "Finish in #{time.round(2)}"

GC.start(full_mark: true, immediate_sweep: true)

puts "rss at finish: #{print_memory_usage}"
