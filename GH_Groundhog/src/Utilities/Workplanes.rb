
module GH
    module Groundhog
        module Utilities

            # Retrieves the Workplane register
            # @author German Molina
            # @return An array of Hash (i.e. the workplanes)
            def self.get_workplanes_registry
				value = Sketchup.active_model.get_attribute(GROUNDHOG_DICTIONARY,WORKPLANES_KEY)
				value = [].to_json if value == nil or not value
				JSON.parse(value)
            end

            # Sets the Workplane register
            # @author German Molina
            # @param value [<Hash>] The workplane register (i.e. an array of Hash)            
            def self.set_workplanes_registry(value)
                Sketchup.active_model.set_attribute(GROUNDHOG_DICTIONARY,WORKPLANES_KEY,value.to_json)
            end


            # Gets the workplanes in a group of entities
			# @author German Molina
			# @param entities [Array<Sketchup::Entities>]
			# @return [Array <Sketchup::Entities>] An array with the entities that are Sketchup::ComponentDefinition
			def self.get_workplanes(entities)
				entities.grep(Sketchup::Face).select{|x| Labeler.get_label(x) == WORKPLANE}
			end

			# Returns the workplane that has a certain name
			#
			# @author German Molina
			# @return [Array<Sketchup::Face>] The workplanes in an array
			# @param wp_name [String] The name of the workplane
			def self.get_workplane_by_name(wp_name)
				
				return [] if not self.workplane_registered? wp_name

				faces = Sketchup.active_model.entities.grep(Sketchup::Face)
				return Utilities.get_workplanes(faces).select{|x| 
					Labeler.get_name(x) == wp_name
				}        		
            end
            
            # Checks if a workplane exists in the register
			#
			# @author German Molina
			# @return [Boolean] Is the workplane registered?
			# @param wp_name [String] The name of the workplane
			def self.workplane_registered?(wp_name)
				self.get_workplanes_registry.each{|wp|					
                    return true if wp_name == wp['name']
                }
                return false                        		
			end

			def self.remove_workplane(wp_name)
				# Remove the workplane itself from the model                    
				faces = Labeler.get_workplane_by_name(wp_name)                    
				entities = Sketchup.active_model.entities                    
				entities.erase_entities(faces)

				# Unregister
				Utilities.unregister_workplane(wp_name)

				# Remove solved workplanes as well
				Utilities.get_solved_workplanes.each{|x|
					v = JSON.parse(Labeler.get_value(x))
					entities.erase_entities(x) if v["workplane"] == wp_name
				}
			end # end of remove_workplane

			# Removes a Workplane from the Groundhog Dictionary list
			#
			# @author German Molina			
			# @param wp_name [String] The name of the workplane
			# @param pass_to_ui [Boolean] Unregister from the UI as well?
			def self.unregister_workplane(wp_name)

				if not self.workplane_registered? wp_name then					
					return
				end

				# First, in the model
                value = self.get_workplanes_registry
                value.each_with_index{|wp,i|					
					if wp['name'] == wp_name then
						value.delete_at(i)                             
						break
					end
				}				
				self.set_workplanes_registry(value)

				# Then in the UI				
				self.pop_workplane_from_ui(wp_name)					           				
				
			end # End of unregister_workplane

			# Registers a new (default) workplane
			#			
			# @author German Molina			
			# @param wp_name [Hash] The name of the Workplane to register
			# @return the default workplane
			def self.register_default_workplane(wp_name)
				default_pixel_size = 0.25
				wp = {"name" => wp_name, "pixel_size" => default_pixel_size, "tasks" => []}
				self.register_workplane(wp)
				return wp
			end
			
			# Registers a new Workplane in the Groundhog Dictionary list
			#
			# @author German Molina			
			# @param wp [Hash] The wp to register
			def self.register_workplane(wp)
				
				# First, in the model				
				value = self.get_workplanes_registry																
				value.push wp
				self.set_workplanes_registry(value)

				# Then in the UI
				push_workplane_to_ui(wp)
				
			end # End of register_workplane


			# Push a workplane in Hash format to the UI
			#
			# @author German Molina
			# @param wp [Hash] The workplane
			def self.push_workplane_to_ui(wp)
				script = "workplanes.push(#{wp.to_json});"
				GH::Groundhog.design_assistant.execute_script(script)
			end

			# Removes a workplane from the UI
			#
			# @author German Molina
			# @param wp_name [String] The workplane's name
			def self.pop_workplane_from_ui(wp_name)
				#script = ""					
				#script += "var i = workplanes.findIndex(function(wp){return wp.name === '#{wp_name}'});"					
				#script += "if(i >= 0){workplanes.splice(i,1)};"					
				GH::Groundhog.design_assistant.execute_script("deleteByName(workplanes,'#{wp_name}');") 
			end

        end
    end
end