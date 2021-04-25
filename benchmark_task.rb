require_relative 'task-2.rb'
require 'benchmark'

time = Benchmark.realtime do
  work(filename = 'data_2000.txt', disable_gc: true)
end

puts "Finish in #{time.round(2)}"
