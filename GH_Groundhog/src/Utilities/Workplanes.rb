
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

			# Removes a Workplane from the Groundhog Dictionary list
			#
			# @author German Molina			
			# @param wp_name [String] The name of the workplane
			# @param pass_to_ui [Boolean] Unregister from the UI as well?
			def self.unregister_workplane(wp_name,pass_to_ui=true)

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
				if pass_to_ui then
					script = ""					
					script += "var i = workplanes.findIndex(function(wp){return wp.name === '#{wp_name}'});"					
					script += "if(i >= 0){workplanes.splice(i,1); console.log('=====>')};"
					
					GH::Groundhog.design_assistant.execute_script(script)            				
				end
			end

			# Registers a new Workplane in the Groundhog Dictionary list
			#
			# @author German Molina			
			# @param wp_name [String] The name of the workplane
			def self.register_workplane(wp_name)
				
				# First, in the model				
				value = self.get_workplanes_registry								
				default_pixel_size = 0.25
				emptyWP = {"name" => wp_name, "pixel_size" => default_pixel_size, "tasks" => []}
				value.push emptyWP
				self.set_workplanes_registry(value)

				# Then in the UI
				script = "workplanes.push({name: '#{wp_name}', pixel_size: #{default_pixel_size}, tasks: []});"
				GH::Groundhog.design_assistant.execute_script(script)
			end

        end
    end
end