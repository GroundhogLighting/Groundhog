module IGD
  module Groundhog
    module Metrics

      @@library = Hash.new

      @@library["DA"] = {
          :read_file => "",
          :write_file => "",
          :get_tasks => Proc.new {},
          :calc_score => Proc.new{}
      }




    end
=begin
    # Objectives are a very important part of Groundhog.
    class Objective

      def initialize(objective_hash)
        @name = objective_hash["name"]
        @good_pixel = objective_hash["good_pixel"]
        @good_light = objective_hash["good_light"]
        @metric = objective_hash["metric"]
        @goal = objective_hash["goal"]
        @dynamic = objective_hash["dynamic"]
        @occupied = objective_hash["occupied"]
        @sim_period = objective_hash["sim_period"]
        @date = objective_hash["date"]

        @read_file = false
        @get_tasks = false
        @calc_score = false
      end

    end
=end
  end
end
