module IGD
	module Groundhog

		# This module contains the methods that handle Labels.
		#
		# Labels are some class-like organization that Groundhog has. Instead of creating a new instance
		# each time we create a window, we just "Label" it by setting an attribute using the set_attribute SketchUp API method.
		#
		# This makes a lighter (I guess??) program, and simplifies event handling. For example, if the user (or some bug)
		# divides a window, the new two faces will inherit all the attributes (i.e they will both be recognized as windows,
		# they will have the same Window Group if they had one, etc). Also, if the user erases some geometry, nothing will happen.
		#
		# Currently existing labels are "workplane", "window", "illum", "added" (for temporal entities).
		# @example Set a name to selected faces.
		#   #We could do a loop over all faces that does:
		#   name="MyName"
		#   entity.set_attribute("Groundhog","Name",name)
		#   #Or we culd call a Labeler methods, and do:
		#   Labeler.set_name(SketchUp.active_model.selection)
		#   #and a prompt will ask for the name to label all the selected faces.
		module Labeler

			# Gets the window group of an entity.
			# @author German Molina
			# @param win [entity] SketchUp entity (although it should be a Window)
			# @return [Int] Window Group of the entity.
			# @note: Will ask for the window group of anything, even if it is not an window.
			def self.get_win_group(win)
				win.get_attribute("Groundhog","Win_Group")
			end

			# Gets the name of an entity.
			# @author German Molina
			# @param entity [entity] SketchUp entity
			# @return [String] Name of the entity.
			# @note: Will ask for the name of anything, even if it is not a face.
			def self.get_name(entity)
				return false if entity.deleted?
				return false if not entity

				#first check User-assigned name
				name=entity.get_attribute("Groundhog","Name")
				return name if (name !=  nil and name != false)
				#Second, check if SketchUp assigns a name to this.
				name = entity.name if entity.respond_to? :name
				return entity.name if (name != nil and name != "")
				#Last, return ID
				return entity.entityID.to_s
			end

			# Checks if the entity has a Groundhog Name assigned
			# @param entity [entity] SketchUp entity 
			# @author Germán Molina
			# @return Boolean
			def self.has_gh_name(entity)
				return false if entity.deleted?
				return false if not entity	
				name = entity.get_attribute("Groundhog","Name")
				return false if (name ==  nil or not name )
				return true
			end

			# Same as get_name but fixing the output (ie. replacing blanks and # by underscores)
			# @author German Molina
			# @param entity [entity] SketchUp entity (should be face)
			# @return [String] Name of the entity.
			# @note: Will ask for the name of anything, even if it is not a face.
			def self.get_fixed_name(entity)
				name = self.get_name(entity)
				return false if not name
				return Utilities.fix_name(name)
			end


			# Assigns the value to a solved workplane
			#
			# The value, in this case, is an array with [min,max] values.
			#
			# @author German Molina
			# @param workplane [SketchUp::ComponentDefinition] The workplane to be assigned the value
			# @param value [Hash] Hash with minimum, maximum and metric
			# @return [Void]
			def self.set_workplane_value(workplane,value)
				if not self.solved_workplane?(workplane) then
					warn "Trying to assign a solved_workplane value to a non-solved_workplane entity!"
					return false
				end
				self.set_value(workplane,value)
			end

			# Assigns the Radiance definition as the value of a Local Material
			#
			# The value, in this case, is an array
			#
			# @author German Molina
			# @param material [Float] The material to be assigned the value
			# @param value [Array<String>] an array of 2 strings, with what goes before the name, and what goes after the name.
			# @return [Boolean] Success
			def self.set_rad_material_value(material,value)
				if not self.rad_material?(material) then
					UI.messagebox "Trying to assign a rad_material value to a non-rad_material entity!"
					return false
				end
				self.set_value(material,value)
				return true
			end


			# Checks if an entity is of some Label.
			# @author German Molina
			# @param entity [SketchUp::Entity] SketchUp entity
			# @param label [String] Label to compare with.
			# @return [Boolean]
			# @example Check if it is window.
			#   Labeler.is?(face,"window")
			def self.is?(entity,label)
				self.get_label(entity)==label
			end

			# Checks if an entity is an illum
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.illum?(entity)
				self.is?(entity, "illum")
			end

			# Checks if a material is a rad_material
			# @author German Molina
			# @param material [entity] Material to test.
			# @return [Boolean]
			def self.rad_material?(material)
				self.is?(material, "rad_material")
			end

			# Checks if a component is a solved_workplane
			# @author German Molina
			# @param group [SketchUp::ComponentDefinition] component to test.
			# @return [Boolean]
			def self.solved_workplane?(group)
				group.get_attribute("Groundhog","Label")=="solved_workplane"
			end

			# Checks if a component is a TDD_top, meaning that it is the exterior lens of the TDD.
			# @author German Molina
			# @param face [SketchUp::Face] face to test.
			# @return [Boolean]
			def self.tdd_top?(face)
				face.get_attribute("Groundhog","Label")=="TDD_top"
			end

			# Checks if a component is a TDD_bottom, meaning that it is the interior lens of the TDD.
			# @author German Molina
			# @param face [SketchUp::Face] face to test.
			# @return [Boolean]
			def self.tdd_bottom?(face)
				face.get_attribute("Groundhog","Label")=="TDD_bottom"
			end

			# Checks if a group is a TDD
			# @author German Molina
			# @param group [SketchUp::ComponentDefinition] component to test.
			# @return [Boolean]
			def self.tdd?(group)
				group.get_attribute("Groundhog","Label")=="TDD"
			end


			# Checks if an entity is an illum
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.result_pixel?(entity)
				entity.get_attribute("Groundhog","Label")=="result_pixel"
			end

			# Checks if an entity is a local_luminaire
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.luminaire?(entity)
				entity.get_attribute("Groundhog","Label")=="luminaire"
			end


			# Checks if an entity is a workplane
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.workplane?(entity)
				entity.get_attribute("Groundhog","Label")=="workplane"
			end

			# Checks if an entity is a window
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.window?(entity)
				entity.get_attribute("Groundhog","Label")=="window"
			end

			# Checks if an entity is a face
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.face?(entity)
				entity.is_a? Sketchup::Face
			end

			# Checks if an entity is a ComponentInstance
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.component_instance?(entity)
				entity.is_a? Sketchup::ComponentInstance
			end


			# Checks if an entity is a Group
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.group?(entity)
				entity.is_a? Sketchup::Group
			end

			# Checks if an entity is an Image
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.image?(entity)
				entity.is_a? Sketchup::Image
			end

			# Checks if an entity is an illuminance_sensor
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.illuminance_sensor?(entity)
				self.get_label(entity) == "illuminance_sensor"
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

				entities = Utilities.get_namables(entities)

				if entities.length==0 then
					UI.messagebox("No selected entities can be named")
					return
				end
				
				entities.each_with_index do |ent,i|
					if Labeler.workplane? ent
						self.replace_workplane(Labeler.get_name(ent),name) 
						IGD::Groundhog::DesignAssistant.update						
					end				
					ent.set_attribute("Groundhog","Name",name) if not Labeler.workplane? ent
				end			
			end

			def self.replace_workplane(old_name,new_name)
				workplanes = Utilities.get_workplane_by_name(old_name)
				hash = JSON.parse Sketchup.active_model.get_attribute("Groundhog","workplanes")
				hash[new_name] = hash[old_name]				
				hash.delete old_name if workplanes.length == 1
				Sketchup.active_model.set_attribute("Groundhog","workplanes",hash.to_json)
			end

			# Assigns a value to a pixel.
			#
			# @author German Molina
			# @param pixel [SketchUp::Face] The pixel to be assigned a value
			# @param value [Float] The value to be assigned
			# @return [Void]
			# @version 0.1
			def self.set_pixel_value(pixel,value)
				warn "Trying to assign a pixel value to a non-result_pixel" if not self.result_pixel?(pixel)
				return false if not self.result_pixel?(pixel)
				self.set_value(pixel,value)
			end


			# Label selected faces as illums
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be transformed into illums.
			# @return [Void]
			def self.to_illum(entities)

				faces=Utilities.get_faces(entities)

				if faces.length>=1 then
					faces.each do |face|
						self.set_label(face,"illum")
						Utilities.set_oriented_surface_materials(face,"illum","green",0.2)
					end
				else
					UI.messagebox("No faces selected")
				end
			end

			# Label selected face as result_pixel
			# @author German Molina
			# @param face [Sketchup Face] The face to be labeled as result_pixels
			# @return [Void]
			def self.to_result_pixel(face)
				self.set_label(face,"result_pixel")
			end

			# Label selected entity as an Illuminance Sensor
			# @author German Molina
			# @param obj [Sketchup::ComponentDefinition] The object to be labeled as illuminance_sensor
			# @return [Void]
			def self.to_illuminance_sensor(obj)
				self.set_label(obj,"illuminance_sensor")
			end

			# Label selected face into as solved_workplane
			# @author German Molina
			# @param workplane [SkecthUp::ComponentDefinition] A SketchUp component definition
			# @return [Void]
			def self.to_solved_workplane(workplane)
				self.set_label(workplane,"solved_workplane")
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

				self.set_label(comp,"luminaire")
				data = Hash.new
				data["ies"] = text


				text.each {|line|
					data["luminaire"] = line.gsub("[LUMINAIRE]","").strip if line.start_with? "[LUMINAIRE]"
					data["manufacturer"] = line.gsub("[MANUFAC]","").strip if line.start_with? "[MANUFAC]"
					data["lamp"] = line.gsub("[LAMP]","").strip if line.start_with? "[LAMP]"
					data["lumcat"] = line.gsub("[LUMCAT]","").strip if line.start_with? "[LUMCAT]"
					data["lampcat"] = line.gsub("[LAMPCAT]","").strip if line.start_with? "[LAMPCAT]"

					break if line.start_with? "TILT="
				}

				self.set_value(comp,data.to_json)

				#update
				DesignAssistant.update
			end

			# Label selected material as rad_material
			# @author German Molina
			# @param material [SkecthUp::ComponentDefinition] A SketchUp material
			# @return [Void]
			def self.to_rad_material(material)
				return false if not material.is_a? Sketchup::Material
				self.set_label(material,"rad_material")
			end


			# Transform selected faces into windows
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as windows.
			# @return [Void]
			def self.to_window(entities)
				faces=Utilities.get_faces(entities)

				if faces.length>=1 then
					mat=Sketchup.active_model.materials["Default 3mm Clear Glass"]
					Materials.add_default_glass if mat==nil
					faces.each do |face|
						self.set_label(face,"window")
						face.material=Sketchup.active_model.materials["Default 3mm Clear Glass"]
						face.back_material=Sketchup.active_model.materials["Default 3mm Clear Glass (back)"]
					end
				else
					UI.messagebox("No faces selected")
				end
			end

			# Label selected faces as workplanes
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as Workplane
			# @version 0.2
			# @return [Void]
			def self.to_workplane(entities)
				faces=Utilities.get_faces(entities)
				name = Utilities.get_name
				return if not name
				already_workplanes = entities.select{|x| Labeler.workplane? x }
				if already_workplanes.length > 0 then
					UI.messagebox "Some of the selected faces are already workplanes... please remove labels before doing this."
					return
				end
				if faces.length > 0 then
					faces.each do |face|
						self.set_name([face],name)
						self.set_label(face,"workplane")
						Utilities.set_oriented_surface_materials(face,"workplane","red",0.2)						
						face.add_observer(WorkplaneObserver.new)
					end

					# Register the workplane... will replace the old one, if it exists.
					model = Sketchup.active_model
					value = model.get_attribute("Groundhog","workplanes")
					value = Hash.new.to_json if value == nil or not value
					value = JSON.parse value
					value[name] = []
					model.set_attribute("Groundhog","workplanes",value.to_json)

					#update
					DesignAssistant.update

				else
					UI.messagebox("No faces selected")
				end
			end

			# Label selected groups as TDDs
			# @author German Molina
			# @param groups [Array<SketchUp::Group>] An array with the groups to be labeled as TDDs
			# @version 0.1
			# @return [Void]
			def self.to_tdd(groups)
				groups.each{|x|
					self.set_label(x, "TDD")
					self.set_label(x.definition, "TDD")
				}
			end

			# Label selected face as TDD top lens
			# @author German Molina
			# @param face [SketchUp::Face] A face
			# @version 0.1
			# @return [Void]
			def self.to_tdd_top(face)
				self.set_label(face,"TDD_top")
				file = UI.openpanel("Choose an BSDF.xml file", "c:/", "XML|*.xml||")
				self.set_value(face,File.readlines(file))
			end

			# Label selected face as TDD bottom lens
			# @author German Molina
			# @param face [SketchUp::Face] A face
			# @version 0.1
			# @return [Void]
			def self.to_tdd_bottom(face)
				self.set_label(face,"TDD_bottom")
				file = UI.openpanel("Choose an BSDF.xml file", "c:/", "XML|*.xml||")
				self.set_value(face,File.readlines(file))
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
								hash = JSON.parse Sketchup.active_model.get_attribute("Groundhog","workplanes")
								hash.delete name
								Sketchup.active_model.set_attribute("Groundhog","workplanes",hash.to_json)
							end							
						end
						self.set_label(i,nil)
						i.material=nil
						i.back_material=nil
					end
				else
					UI.messagebox("No faces selected")
				end
			end

			# Get Groundhog-assigned value of an entity
			#
			# It is important to notice that, depending on the kind of entity and label,
			# there will be different kinds of "values". For example,
			# the value for Solved Workplanes is an array with [min,max] values. Result pixels,
			# on the other hand, will return a float.
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @return [Variable] Value
			def self.get_value(entity)
				entity.get_attribute("Groundhog","Value")
			end

			# returns the label of an Entity
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @return [Variable] Label
			def self.get_label(entity)
				entity.get_attribute("Groundhog","Label")
			end

			# Sets the Groundhog-assigned value to an entity
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to set the value to
			# @param value [] The value to be assigned
			def self.set_value(entity, value)
				entity.set_attribute("Groundhog","Value", value)
				return true
			end

			# Sets the Groundhog-assigned label an entity
			#
			# @author German Molina
			# @param entity [SketchUp::Entity] The entity to get the value from
			# @param label [String] The label to be assigned
			def self.set_label(entity, label)
				if self.workplane? entity then
					warn "it is a workplane!"
					# erase it.
					name = self.get_name(entity)
					warn "the name is #{name}"
					workplanes = Utilities.get_workplane_by_name(name)
					if workplanes.length == 1 then
						warn "only one of them."
						hash = JSON.parse Sketchup.active_model.get_attribute "Groundhog","workplanes"
						hash.delete name
						Sketchup.active_model.set_attribute("Groundhog","workplanes",hash.to_json)
						DesignAssistant.update
					end
				end
				entity.set_attribute("Groundhog","Label", label)
			end


		end #end Labeler module

	end #end module
end
