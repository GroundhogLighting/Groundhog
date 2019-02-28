module GH
    module Groundhog
        module Labeler
			
			# returns the label of an Entity
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @return [Variable] Label
			def self.get_label(entity)
				entity.get_attribute(GROUNDHOG_DICTIONARY,LABEL_KEY)
			end

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
						Utilities.unregister_workplane(name)						
					end
                end
                # Then, label
				entity.set_attribute(GROUNDHOG_DICTIONARY,LABEL_KEY, label)
			end
			
			# Sets the Groundhog-assigned value to an entity
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @param value The value to be assigned			
            def self.set_value(entity,value)                                
				entity.set_attribute(GROUNDHOG_DICTIONARY,VALUE_KEY, value)
			end
			
			# Gets the Groundhog-assigned value to an entity
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @param value The value to be assigned			
            def self.get_value(entity)                                
				entity.get_attribute(GROUNDHOG_DICTIONARY,VALUE_KEY)
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
                    if self.workplane?(ent) then
						# If it is a workplane, the registry may to change
						old_name = self.get_name(ent)												

						# If the new workplane does not exist, register it
						if not Utilities.workplane_registered?(name) then
							Utilities.register_default_workplane(name)
						end

						# If the old workplane will get empty, unregister it
						if Utilities.get_workplane_by_name(old_name).length == 1 then
							Utilities.unregister_workplane(old_name)
						end

						# Set observer again.
						ent.add_observer(WorkplaneObserver.new)
						
                    end	
					ent.set_attribute(GROUNDHOG_DICTIONARY,NAME_KEY,name)
                end			
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

			# Checks if an entity is a window
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.window?(entity)
				self.get_label(entity) == WINDOW
			end

			# Checks if an entity is a luminaire
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.luminaire?(entity)
				self.get_label(entity) == LUMINAIRE
			end

			# Checks if an entity is a workplane
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.workplane?(entity)
				self.get_label(entity) == WORKPLANE
			end

			# Checks if an entity is a Illum
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.illum?(entity)
				self.get_label(entity) == ILLUM
			end

			# Checks if an entity is a Illum
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.photosensor?(entity)
				self.get_label(entity) == PHOTOSENSOR
			end

			# Label selected faces as illums
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as Workplane			
			# @return [Void]
			def self.to_illum(entities)
				# Check if there are faces
				faces=Utilities.get_faces(entities)
				if faces.length < 1 then
					UI.messagebox "There are no faces in your selection. Please try again with another selection"
					return
				end
				faces.each{|face|
					self.label_as(face,ILLUM)
				}
			end

			# Label selected definitions as photosensor
			# @author German Molina
			# @param definition [Sketchup::ComponentDefinition] the definition
			# @return [Void]
			def self.to_photosensor(definition)				
				self.label_as(definition,PHOTOSENSOR)				
			end

			# Label selected faces as windows
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as Workplane			
			# @return [Void]
			def self.to_illum(entities)
				# Check if there are faces
				faces=Utilities.get_faces(entities)
				if faces.length < 1 then
					UI.messagebox "There are no faces in your selection. Please try again with another selection"
					return
				end

				faces.each{|face|
					self.label_as(face,ILLUM)
					Utilities.set_oriented_surface_materials(face,"illum","green",0.2)
				}
			end

			# Label selected faces as windows
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as Workplane			
			# @return [Void]
			def self.to_window(entities)
				# Check if there are faces
				faces=Utilities.get_faces(entities)
				if faces.length < 1 then
					UI.messagebox "There are no faces in your selection. Please try again with another selection"
					return
				end

				faces.each{|face|
					self.label_as(face,WINDOW)
					Utilities.set_oriented_surface_materials(face,"window","blue",0.2)
				}
			end

			# Label selected faces as workplanes
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as Workplane			
			# @return [Void]
			def self.to_workplane(entities)

				# Check if there are faces
				faces=Utilities.get_faces(entities)
				if faces.length < 1 then
					UI.messagebox "There are no faces in your selection. Please try again with another selection"
					return
				end

				# Ask for a name... return if 'cancel'
				name = Utilities.get_name_from_user				
				return if not name
								
				# Start operation
				model = Sketchup.active_model
				
				
				faces.each do |face|
				
					# Check if there is a workplane in the selection
					if Labeler.workplane?(face) then
						UI.messagebox "Some of the selected faces are already workplanes... please remove labels before doing this."						
						model.abort_operation
						return
					end

					self.set_name([face],name)
					self.label_as(face,WORKPLANE)
					Utilities.set_oriented_surface_materials(face,"workplane","red",0.2)						
					face.add_observer(WorkplaneObserver.new)
				end				

				# Register the workplane				
				if not Utilities.workplane_registered?(name) then
					Utilities.register_default_workplane(name) 					
				end				
			
			end


			# Delete label from entities
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>] An array with the entities whose Label will be removed
			# @return [Void]
			def self.to_nothing(entities)
				faces=Utilities.get_faces(entities)
				if faces.length>=1 then
					faces.each do |i|
						if self.workplane? i then
							name = self.get_name(i)
							wps = Utilities.get_workplane_by_name(name)
							if wps.length == 1 then
								Utilities.unregister_workplane(name)
							end							
						end
						if self.workplane?(i) or self.window?(i) or self.illum?(i) then
							i.material=nil
							i.back_material=nil
						end
						self.label_as(i,nil)
					end
				else
					UI.messagebox("No faces selected")
				end
			end

			# Label selected face into as solved_workplane
			# @author German Molina
			# @param workplane [SkecthUp::ComponentDefinition] A SketchUp component definition
			# @return [Void]
			def self.to_solved_workplane(workplane)
				self.label_as(workplane,SOLVED_WORKPLANE)				
			end

			# Checks if a component is a solved_workplane
			# @author German Molina
			# @param group [SketchUp::ComponentDefinition] component to test.
			# @return [Boolean]
			def self.solved_workplane?(group)
				self.get_label(group) == SOLVED_WORKPLANE
			end

			# Label selected face into as local_luminaire
			# @author German Molina
			# @param comp [SkecthUp::ComponentDefinition] A SketchUp component definition
			# @return [Void]
			def self.to_luminaire(comp)
				UI.messagebox("Only components can be labeled as Luminaires") if not comp.is_a? Sketchup::ComponentDefinition
				return if not comp.is_a? Sketchup::ComponentDefinition


				lumfile = UI.openpanel("Choose an IES file", "c:/", "IES|*.ies||")
				return false if not lumfile
				text = File.readlines(lumfile)

				self.label_as(comp,LUMINAIRE)
				data = Hash.new
				data["ies"] = text


				text.each {|line|
					data["name"] = line.gsub("[LUMINAIRE]","").strip if line.start_with? "[LUMINAIRE]"
					data["manufacturer"] = line.gsub("[MANUFAC]","").strip if line.start_with? "[MANUFAC]"
					data["lamp"] = line.gsub("[LAMP]","").strip if line.start_with? "[LAMP]"
					data["lumcat"] = line.gsub("[LUMCAT]","").strip if line.start_with? "[LUMCAT]"
					data["lampcat"] = line.gsub("[LAMPCAT]","").strip if line.start_with? "[LAMPCAT]"
					data["multiplier"] = 1 # By default... dimmed from UI.
					break if line.start_with? "TILT="
				}

				self.set_value(comp,data.to_json)

				#update UI
				data.delete("ies")
				Error.log data.inspect
				script = "luminaires.push(#{data.to_json});"
				GH::Groundhog.design_assistant.execute_script(script)
				# DesignAssistant.update
			end

        end
    end
end