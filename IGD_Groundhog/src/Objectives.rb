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
      # @param objective_name [Hash] The objective in Hash format
      # @author Germán Molina
      def self.add_objective_to_workplane(wp_name,objective_name)
        # Register the workplane... will replace the old one, if it exists.
        model = Sketchup.active_model
        value = model.get_attribute("Groundhog","workplanes")
        Error.inform_exception("Model has no registered workplanes!") if value == nil or not value
        value = JSON.parse value

        Error.inform_exception("Model has not registered workplane '#{wp_name}'!") if not value.key? wp_name
        value[wp_name] << objective_name
        model.set_attribute("Groundhog","workplanes",value.to_json)
=begin
        wps = Utilities.get_workplane_by_name(wp_name)
        wps.each{|wp|
          value = Labeler.get_value(wp)
          value = "[]" if value == nil or not value
          value = JSON.parse(value)
          value << objective["name"] #only the name is stored
          Labeler.set_value(wp,value.to_json)
        }
=end
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
        wp_names = Utilities.get_workplanes(Sketchup.active_model.entities).map{|x| Labeler.get_name(x)}.uniq
        wp_names.each{|wp_name|
          Objectives.remove_objective_from_workplane(wp_name,objective_name)
        }
      end

      # Removes an objective from a certain workplane, avoiding future calculations.
      #
      # @param wp_name [String] The name of the workplane
      # @param objective_name [String] The name of the objective
      # @author Germán Molina
      def self.remove_objective_from_workplane(wp_name,objective_name)


        # Register the workplane... will replace the old one, if it exists.
        model = Sketchup.active_model
        value = model.get_attribute("Groundhog","workplanes")
        Error.inform_exception("Model has not registered any workplanes!") if value == nil or not value
        value = JSON.parse value

        Error.inform_exception("Model has not registered workplane '#{wp_name}'!") if not value.key? wp_name
        value[wp_name].delete(objective_name)
        model.set_attribute("Groundhog","workplanes",value.to_json)


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
