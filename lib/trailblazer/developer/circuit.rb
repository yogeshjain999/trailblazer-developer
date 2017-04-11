require 'securerandom'

module Trailblazer
  module Developer
    module Circuit
      Task = Struct.new(:id, :name, :outgoing, :incoming)
      Flow = Struct.new(:id, :source, :target)

      Model = Struct.new(:start_events, :end_events, :task, :flows)

      module_function
      def bla(circuit)
        flow_map = FlowMap.new
        task_map = TaskMap.new

        sequence_flows = []

        map, stop_events, debug = circuit.to_fields

        stop_events.each { |evt| task_map[evt, debug[task] || "End.#{task}"] }

        map.each do |task, connections|
          id = debug[task] || task.to_s

          _task = task_map[task, id]
          # outgoing
          _task.outgoing = map[task].collect { |direction, target| flow_map[_task, direction, task_map[target, debug[target]]] }

          # incoming
          _task.incoming = map.collect { |source, hsh| hsh.find_all { |direction, target| target==task }
            .collect { |direction, target| [direction, source] } }.flatten.each_cons(2)
            .collect { |direction, source| flow_map[task_map[source, debug[source]], direction, _task] }
        end


        puts task_map.inspect

        map.each do |task, connections|
          # tasks[task].
        end

        model = Model.new([], [], task_map.values, flow_map.values)
      end

      class FlowMap < Hash
        def [](source, direction, target)
          key = [source.id, direction, target.id]

          super(key) or self[key] = Flow.new(Circuit.get_id("Flow"), source, target)
        end
      end

      class TaskMap < Hash
        def [](step, name)
          key = step

          super(key) or self[key] = Task.new(Circuit.get_id("Task"), name, [], [])
        end
      end

      def get_id(prefix)
        "#{prefix}_#{SecureRandom.hex[0..8]}"
      end
    end
  end
end