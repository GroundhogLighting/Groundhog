module IGD
  module Groundhog
    module Objectives

      # Gets the hash of objectives stored in the Model dictionary.
      # This hash is used for performing calculations and updating the Design Assistant.
      #
      # @author Germán Molina
      # @return [Hash] The objectives hash
      def self.get_objectives_hash
        JSON.parse Sketchup.active_model.get_attribute("Groundhog","objectives")
      end

      # Receives an objective (in Hash format), and stores it in the model dictionary.
      #
      # @param objective [Hash] The objective in Hash format.
      # @author Germán Molina
      def self.create_objective(objective)
        name = objective["name"]
        objs = JSON.parse Sketchup.active_model.get_attribute("Groundhog","objectives")
        objs[name] = objective #replaces if needed
        Sketchup.active_model.set_attribute("Groundhog","objectives",objs.to_json)
      end

      # Adds a certain objective to a certain workplane. That is, adds it to the
      # array containing objectives names in the workplane's value.
      #
      # @param wp_name [String] The workplane name
      # @param objective [Hash] The objective in Hash format
      # @author Germán Molina
      def self.add_objective_to_worplane(wp_name,objective)
        wp = Utilities.get_workplane_by_name(wp_name)

        value = Labeler.get_value(wp)
        value = "[]" if value == nil or not value
        value = JSON.parse(value)
        value << objective["name"] #only the name is stored
        Labeler.set_value(wp,value.to_json)
      end

      # Removes an objective completely from the model.
      #
      # @author Germán Molina
      # @param objective_name [String] The name of the objective to remove
      def self.delete_objective(objective_name)
        #delete it from the main list
        objs = JSON.parse Sketchup.active_model.get_attribute("Groundhog","objectives")
        objs.delete(objective_name)
        Sketchup.active_model.set_attribute("Groundhog","objectives",objs.to_json)

        #deletete it from the workplanes... and remove the solved workplane, if it exist
        Utilities.get_workplanes(Sketchup.active_model.entities).select{|x|
          wp_name = Labeler.get_name(x)
          Objectives.remove_objective_from_workplane(wp_name,objective_name)
        }
      end

      # Removes an objective from a certain workplane, avoiding future calculations.
      #
      # @param wp_name [String] The name of the workplane
      # @param obejctive_name [String] The name of the objective
      # @author Germán Molina
      def self.remove_objective_from_workplane(wp_name,objective_name)
        #find the workplane
        workplane = Utilities.get_workplane_by_name(wp_name)

        #delete the objective from the workplane value
        value = JSON.parse Labeler.get_value(workplane)   #this is an array of hash
        value.delete(objective_name) #delete the first one.
        Labeler.set_value(workplane, value.to_json)

        #delete the solved workplane if it exist.
        IGD::Groundhog::Utilities.get_solved_workplanes(Sketchup.active_model.entities).select{|x|
          JSON.parse(IGD::Groundhog::Labeler.get_value(x))["objective"]==objective_name
        }.select {|x|
          JSON.parse(IGD::Groundhog::Labeler.get_value(x))["workplane"]==wp_name
        }.each{|x|
          x.erase!
        }
      end



    end
  end
end
