
module GH
    module Groundhog
        module Utilities
            
            # Retrieves the Task register
            # @author German Molina
            # @return An array of Hash (i.e. the tasks)
            def self.get_tasks_registry
				value = Sketchup.active_model.get_attribute(GROUNDHOG_DICTIONARY,TASKS_KEY)
				value = [].to_json if value == nil or not value
				JSON.parse(value)
            end

            # Sets the Task register
            # @author German Molina
            # @param value [<Hash>] The task registry (i.e. an array of Hash)            
            def self.set_tasks_registry(value)
                Sketchup.active_model.set_attribute(GROUNDHOG_DICTIONARY,TASKS_KEY,value.to_json)
            end

            # Push a task in Hash format to the UI
			#
			# @author German Molina
			# @param task [Hash] The workplane
			def self.push_task_to_ui(task)
				script = "tasks.push(#{task.to_json});"
				GH::Groundhog.design_assistant.execute_script(script)
			end

			# Removes a task from the UI
			#
			# @author German Molina
			# @param name [String] The Task's name
			def self.pop_task_from_ui(name)
				script = ""					
				script += "var i = tasks.findIndex(function(t){return t.name === '#{name}'});"					
				script += "if(i >= 0){tasks.splice(i,1)};"					
				GH::Groundhog.design_assistant.execute_script(script) 
            end
            
            # Removes a Task from the Groundhog Dictionary list
			#
			# @author German Molina			
			# @param name [String] The task of the workplane
			# @param pass_to_ui [Boolean] Unregister from the UI as well?
			def self.unregister_task(name,pass_to_ui=true)

				if not self.task_registered? wp_name then					
					return
				end

				# First, in the model
                value = self.get_tasks_registry
                value.each_with_index{|task,i|					
					if task['name'] == name then
						value.delete_at(i)                             
						break
					end
				}				
				self.set_tasks_registry(value)

				# Then in the UI
				if pass_to_ui then
					self.pop_task_from_ui(wp_name)					           				
				end
            end # End of unregister task
            
            # Registers a new Workplane in the Groundhog Dictionary list
			#
			# @author German Molina			
			# @param task [Hash] The name of the workplane
			def self.register_task(task)				
				# First, in the model				
				value = self.get_tasks_registry												
				value.push task
				self.set_tasks_registry(value)				
			end # End of register_workplane

        end
    end
end