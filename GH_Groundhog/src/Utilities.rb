module GH
    module Groundhog
        module Utilities


			# Returns all the Sketchup::Face within an array.
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>] Array with entities.
			# @return [Array<Sketchup::Faces>] An array of faces.
            def self.get_faces(entities)
				entities.grep(Sketchup::Face)
            end
            
            # Returns all the Sketchup::Group within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Sketchup::Faces] An array of faces.
            def self.get_groups(entities)
				entities.grep(Sketchup::Group)
            end
            
            # Gets the entities in an array that are SketchUp::ComponentDefinition
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that are SketchUp::ComponentDefinition
            def self.get_components(entities)
				entities.grep(Sketchup::ComponentInstance)
            end
            
            # Gets the entities in an array that can be named
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that can be named
			def self.get_nameables(entities)
				entities.select{|x| self.nameable?(x)}
			end

            # Tells if a Sketchup::Entity can be assigned a name.
			# @author German Molina
			# @param entity [Array<SketchUp::Entities>]
			# @return [Boolean]
            def self.nameable?(entity)
				entity.is_a? Sketchup::ComponentInstance or entity.is_a? Sketchup::Group or entity.is_a? Sketchup::Face
            end
            
            # Ask the user for a name
			# @author German Molina
			# @return [String] The asigned name
            def self.get_name_from_user
				name = UI.inputbox ["Name\n"], [""], "Assign a name"
				return false if not name
				return name[0]
            end
            
            # Returns all the windows within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Array<faces>] An array of faces.
            def self.get_windows(entities)
				entities.select {|x| Labeler.window?(x)}
			end


        end
    end
end