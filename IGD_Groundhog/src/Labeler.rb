module IGD
	module Groundhog

		# This class contains the methods that handle Labels.
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
			# @param entity [entity] SketchUp entity (should be face)
			# @return [String] Name of the entity.
			# @note: Will ask for the name of anything, even if it is not a face.
			def self.get_name(entity)
				name=entity.get_attribute("Groundhog","Name")
				if name == nil then
					entity.entityID.to_s
				else
					name
				end
			end

			# Assigns the maximum and minimum value to a solved workplane
			#
			# The value, in this case, is an array with [min,max] values.
			#
			# @author German Molina
			# @param workplane [SketchUp::ComponentDefinition] The workplane to be assigned the value
			# @param min [Float] Minimum value
			# @param max [Float] Maximum value
			# @return [Void]
			def self.set_workplane_value(workplane,min,max)
				return false if not self.solved_workplane?(workplane)
				workplane.set_attribute("Groundhog","Value",[min,max])
			end

			# Assigns the Radiance definition as the value of a Local Material
			#
			# The value, in this case, is an array
			#
			# @author German Molina
			# @param material [Float] The material to be assigned the value
			# @param value [Array<String>] an array of 2 strings, with what goes before the name, and what goes after the name.
			# @return [Boolean] Success
			def self.set_local_material_value(material,value)
				return false if not self.local_material?(material)
				material.set_attribute("Groundhog","Value",value)
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
				entity.get_attribute("Groundhog","Label")==label
			end

			# Checks if an entity is an illum
			# @author German Molina
			# @param entity [entity] Entity to test.
			# @return [Boolean]
			def self.illum?(entity)
				entity.get_attribute("Groundhog","Label")=="illum"
			end

			# Checks if a material is a local_material
			# @author German Molina
			# @param material [entity] Material to test.
			# @return [Boolean]
			def self.local_material?(material)
				material.get_attribute("Groundhog","Label")=="local_material"
			end

			# Checks if a component is a solved_workplane
			# @author German Molina
			# @param component_definition [SketchUp::ComponentDefinition] component to test.
			# @return [Boolean]
			def self.solved_workplane?(component_definition)
				component_definition.get_attribute("Groundhog","Label")=="solved_workplane"
			end


			# Checks if an entity is an illum
			# @author German Molina
			# @param entity [SketchUp::Entity] Entity to test.
			# @return [Boolean]
			def self.result_pixel?(entity)
				entity.get_attribute("Groundhog","Label")=="result_pixel"
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
				entity.get_attribute("Groundhog","Label")=="illuminance_sensor"
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
				else
					#return false if not name

					if entities.length==1 then
						entities[0].set_attribute("Groundhog","Name",name)
					else
						n=0
						entities.each do |ent|
							n+=1
							ent.set_attribute("Groundhog","Name",name+"_#{n.to_s}")
						end
					end
				end
			end

			# Assigns a value to a pixel.
			#
			# @author German Molina
			# @param pixel [SketchUp::Face] the pixel to be assigned a value
			# @param value [Float] the value to be assigned
			# @return [Void]
			def self.set_pixel_value(pixel,value)
				pixel.set_attribute("Groundhog","Value",value)
			end

			# Label selected faces as illums
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be transformed into illums.
			# @return [Void]
			def self.to_illum(entities)

				faces=Utilities.get_faces(entities)

				if faces.length>=1 then
					faces.each do |i|
						i.set_attribute("Groundhog","Label","illum")
						i.material=[0.0,1.0,0.0]
						i.material.alpha=0.2
						i.back_material=[0.0,1.0,0.0]
						i.back_material.alpha=0.2
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
				face.set_attribute("Groundhog","Label","result_pixel")
			end

			# Label selected entity as an Illuminance Sensor
			# @author German Molina
			# @param entity [Sketchup Face] The entity (Component Definition or Component Instance) to be labeled as illuminance_sensor
			# @return [Void]
			def self.to_illuminance_sensor(face)
				face.set_attribute("Groundhog","Label","illuminance_sensor")
			end

			# Label selected face into as solved_workplane
			# @author German Molina
			# @param workplane [SkecthUp::ComponentDefinition] A SketchUp component definition
			# @return [Void]
			def self.to_solved_workplane(workplane)
				workplane.set_attribute("Groundhog","Label","solved_workplane")
			end

			# Label selected material as local_material
			# @author German Molina
			# @param workplane [SkecthUp::ComponentDefinition] A SketchUp material
			# @return [Void]
			def self.to_local_material(workplane)
				workplane.set_attribute("Groundhog","Label","local_material")
			end


			# Transform selected faces into windows
			# @author German Molina
			# @param entities [Array<entities>] An array with the entities to be labeled as windows.
			# @return [Void]
			def self.to_window(entities)
				faces=Utilities.get_faces(entities)

				if faces.length>=1 then
					mat=Sketchup.active_model.materials["GH_default_glass"]
					Materials.add_default_glass if mat==nil
					faces.each do |i|
						i.set_attribute("Groundhog","Label","window")
						i.material=Sketchup.active_model.materials["GH_default_glass"]
						i.back_material=Sketchup.active_model.materials["GH_default_glass"]
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
				faces=Utilities.get_horizontal_faces(entities)
				not_sutable=false
				correct=[]
				name = Utilities.get_name
				return if not name
				if faces.length>=1 then
					faces.each do |i|
						if i.vertices.count!=4 or i.loops.count!=1 then
							#not rectangular faces are ignored, as well as those with holes (more than 1 loop)
							not_sutable=true
							next
						end
						correct=correct+[i]
						i.set_attribute("Groundhog","Label","workplane")
						i.material=[1.0,0.0,0.0]
						i.material.alpha=0.2
						i.back_material=[1.0,0.0,0.0]
						i.back_material.alpha=0.2
					end

					Labeler.set_name(correct,name)
					UI.messagebox("Non-rectangular faces were ignored, as well as those with holes.") if not_sutable
				else
					UI.messagebox("No faces selected")
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
						i.set_attribute("Groundhog","Label",nil)
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


		end #end Labeler module

	end #end module
end
