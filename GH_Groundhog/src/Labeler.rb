module GH
    module Groundhog
        module Labeler
            
            # Sets the Groundhog-assigned label an entity
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @param label [int] The label to be assigned			
            def self.label_as(entity,label)
                # Delete it if the entity is a workplane and the label is being
                # changed... and if there is only one face in the model labeled 
                # as WORKPLANE with such name
                if self.is_labeled?(entity,WORKPLANE) and label != WORKPLANE  then
					# erase it.
					name = self.get_name(entity)
					workplanes = Utilities.get_workplane_by_name(name)
					if workplanes.length == 1 then
						hash = JSON.parse Sketchup.active_model.get_attribute "Groundhog","workplanes"
						hash.delete name
						Sketchup.active_model.set_attribute(GROUNDHOG_DICTIONARY,WORKPLANES_KEY,hash.to_json)
						#DesignAssistant.update
					end
                end
                # Then, label
				entity.set_attribute(GROUNDHOG_DICTIONARY,LABEL_KEY, label)
            end

            # Checks if an entity has a certain label 
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @param label [int] The label to be assigned	
            def self.is_labeled?(entity,label)
                l = entity.get_attribute(GROUNDHOG_DICTIONARY,LABEL_KEY)
                return false if l == nil
                label == l
            end

            # Assigns a name to a set of faces.
			#
			# If there is only one surface, the name will be the inputted on the prompt. If there
			# is more than one face selected, the names will be numbered.
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be assigned a name.
			# @param name [String] The name to assign
			# @return [Boolean] Success
			# @example Name one selected face
			#   Labeler.set_name(Sketchup.active_model.selection[0],"MyName")
			#    # The resulting name will be "MyName".
			# @example Name two selected faces
			#   # if "MyName" was chosen in the prompt
			#   Labeler.set_name([Sketchup.active_model.selection[0], Sketchup.active_model.selection[1]],"MyName")
			#    # The resulting names will be "MyName_1" and "MyName_2".
            def self.set_name(entities,name)
                
                entities = Utilities.get_nameables(entities)

                if entities.length == 0 then
                    UI.messagebox("No selected entities can be named")
                    return
                end
                
                entities.each do |ent|													
                    if self.is_labeled?(ent,WORKPLANE) then
                        self.replace_workplane(Labeler.get_name(ent),name) 
                        #IGD::Groundhog::DesignAssistant.update						
                    end	
                    ent.set_attribute(GROUNDHOG_DICTIONARY,NAME_KEY,name)
                end			
            end

            # Replaces the name of a workplane, updating the model dictionary
            #
            # @author German Molina
            # @param old_name The current name of the workplane
            # @param new_name The new name for the workplane
            def self.replace_workplane(old_name,new_name)
				workplanes = Utilities.get_workplane_by_name(old_name)
				hash = JSON.parse Sketchup.active_model.get_attribute(GROUNDHOG_DICTIONARY,WORKPLANES_KEY)
				hash[new_name] = hash[old_name]				
				hash.delete old_name if workplanes.length == 1
				Sketchup.active_model.set_attribute(GROUNDHOG_DICTIONARY,WORKPLANES_KEY,hash.to_json)
            end
            
            # Returns the workplane that has a certain name
			#
			# @author German Molina
			# @return [Array<SketchUp::Face>] The workplanes in an array
			# @param wp_name [String] The name of the workplane
			def self.get_workplane_by_name(wp_name)
                return Utilities.get_workplanes(Sketchup.active_model.entities).select{|x| 
                    self.get_name(x)==wp_name
                }
            end
            

            # Gets the name of an entity.
            #
			# @author German Molina
			# @param entity [entity] SketchUp entity
			# @return [String] Name of the entity.
			# @note: Will ask for the name of anything, even if it is not a face.
			def self.get_name(entity)
				return false if entity.deleted?
				return false if not entity

				#first check User-assigned name
				name=entity.get_attribute(GROUNDHOG_DICTIONARY,NAME_KEY)
				return name if (name !=  nil and name != false)
				#Second, check if SketchUp assigns a name to this.
				name = entity.name if entity.respond_to? :name
				return entity.name if (name != nil and name != "")
				#Last, return ID
				return entity.entityID.to_s
			end




        end
    end
end