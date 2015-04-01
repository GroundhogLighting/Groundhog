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
#   #Or we culd call a GH_Labeler methods, and do:
#   GH_Labeler.set_name(SketchUp.active_model.selection) 
#   #and a prompt will ask for the name to label all the selected faces.
class GH_Labeler

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



	# Checks if an entity is of some Label.
	# @author German Molina
	# @param entity [entity] SketchUp entity
	# @param label [String] Label to compare with.
	# @return [Boolean]
	# @example Check if it is window.
	#   GH_Labeler.is?(face,"window")
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

	# Checks if an entity is a workplane
	# @author German Molina
	# @param entity [entity] Entity to test.
	# @return [Boolean]
	def self.workplane?(entity)
		entity.get_attribute("Groundhog","Label")=="workplane"
	end

	# Checks if an entity is a window
	# @author German Molina
	# @param entity [entity] Entity to test.
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

	# Checks if an entity is a ComponentDefinition
	# @author German Molina
	# @param entity [entity] Entity to test.
	# @return [Boolean]
	def self.component_definition?(entity)
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
	
	# Assigns a name to a set of faces.
	#
	# If there is only one surface, the name will be the inputted on the prompt. If there
	# is more than one face selected, the names will be numbered.
	# @author German Molina
	# @param entities [Array<entities>] An array with the entities to be assigned a name.
	# @return [Void]
	# @example Name one selected face
	#   # if "MyName" was chosen in the prompt
	#   GH_Labeler.set_name(Sketchup.active_model.selection[0])
	#    # The resulting name will be "MyName".
	# @example Name two selected faces
	#   # if "MyName" was chosen in the prompt
	#   GH_Labeler.set_name([Sketchup.active_model.selection[0], Sketchup.active_model.selection[1]])
	#    # The resulting names will be "MyName_1" and "MyName_2".
	def self.set_name(entities)
	
		faces=GH_Utilities.get_faces(entities)
		
		if faces.length==0 then
			UI.messagebox("No faces selected")
		else
			prompts = ["Name\n"] #get the name
			defaults = [""]
			name = UI.inputbox prompts, defaults, "Assign a name"
				
			if faces.length==1 then
				faces[0].set_attribute("Groundhog","Name",name[0])
			else
				n=0
				faces.each do |face|
					n+=1
					face.set_attribute("Groundhog","Name",name[0]+"_#{n.to_s}")
				end	
			end
		end
	end

	
	# Transform selected faces into illums
	# @author German Molina
	# @param entities [Array<entities>] An array with the entities to be assigned a CFS.
	# @return [Void]
	def self.to_illum(entities)
	
		faces=GH_Utilities.get_faces(entities)
	
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

	# Transform selected faces into windows
	# @author German Molina
	# @param entities [Array<entities>] An array with the entities to be assigned a CFS.
	# @return [Void]
	def self.to_window(entities)
		faces=GH_Utilities.get_faces(entities)
	
		if faces.length>=1 then
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
	# @param entities [Array<entities>] An array with the entities to be declared as Workplane
	# @version 0.2
	# @return [Void]
	def self.to_workplane(entities)
		faces=GH_Utilities.get_horizontal_faces(entities)
		not_sutable=false
		correct=[]
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
			GH_Labeler.set_name(correct)
			UI.messagebox("Non-rectangular faces were ignored, as well as those with holes.") if not_sutable
		else
			UI.messagebox("No faces selected")
		end	
	end
	
	# Delete label from entities
	# @author German Molina
	# @param entities [Array<entities>] An array with the entities to be assigned a CFS.
	# @return [Void]
	def self.to_nothing(entities)
		faces=GH_Utilities.get_faces(entities)
	
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


end #end class

