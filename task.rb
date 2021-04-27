# valgrind --tool=massif ruby task.rb
# mv massif.out.XXXX massif.out.1
# massif-visualizer massif.out.1

require_relative 'task-2.rb'

work(filename = 'data_32000.txt', disable_gc: false)

