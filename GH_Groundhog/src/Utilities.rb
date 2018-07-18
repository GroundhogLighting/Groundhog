require_relative "./Utilities/Workplanes"
require_relative "./Utilities/Tasks"
require_relative "./Utilities/Materials"

module GH
    module Groundhog
        module Utilities

			# Gets the path where the SketchUp model is saved. If it is not saved, it will return false.
			# @author German Molina
			# @version 1.0
			# @return [String] Path where the model is saved.
			# @example Get the path
			#   path=Exporter.getpath
			def self.get_current_path
				model=Sketchup.active_model
				path=model.path
				return false if path=="" #model has not been saved

				path=path.tr("\\","/") #normalize Windows paths into Ruby paths (with /)
				path=path.split("/")
				path.pop #drop the name of the file
				return File.join(path)
			end

			# Some Radiance surface (thus, Groundhog surface) have an orientation that
			# actually matters. Workplanes, Windows, etc.
			#
			# This method sets the materials for  such kind of labeled surfaces, adding a texture
			# on their back in order to allow easy identification of each side.
			#
			# @author German Molina
			# @param face [Sketchup::Face] The face to treat
			# @param label [String] The label assigned
			# @param color [String] The color assigned to the surface (i.e. Red, Blue)
			# @param alpha [Int] The opacity of the surface.
			# @note The label input only sets the name of the materials. It does not really Label.
			def self.set_oriented_surface_materials(face,label,color,alpha)
				back_material = Sketchup.active_model.materials["back_#{label}_material"]
				if back_material == nil then #create it
					back_material = Sketchup.active_model.materials.add("back_#{label}_material")
					back_material.texture = "#{OS.main_groundhog_path}/Assets/Images/back_material_texture.jpg"
					back_material.texture.size = 5
					back_material.color = color
					back_material.alpha=alpha
				end
				face.back_material = back_material

				material = Sketchup.active_model.materials["#{label}_material"]
				if material == nil then #create it
					material = Sketchup.active_model.materials.add("#{label}_material")
					material.color = color
					material.alpha=alpha
				end
				face.material = material
			end

			# Returns all the Sketchup::Face within an array.
			# @author German Molina
			# @param entities [Array<Sketchup::Entities>] Array with entities.
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
            
            # Gets the entities in an array that are Sketchup::ComponentDefinition
			# @author German Molina
			# @param entities [Array<Sketchup::Entities>]
			# @return [Array <Sketchup::Entities>] An array with the entities that are Sketchup::ComponentDefinition
            def self.get_components(entities)
				entities.grep(Sketchup::ComponentInstance)
            end
            
            # Gets the entities in an array that can be named
			# @author German Molina
			# @param entities [Array<Sketchup::Entities>]
			# @return [Array <Sketchup::Entities>] An array with the entities that can be named
			def self.get_nameables(entities)
				entities.select{|x| self.nameable?(x)}
			end

            # Tells if a Sketchup::Entity can be assigned a name.
			# @author German Molina
			# @param entity [Array<Sketchup::Entities>]
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
				entities.grep(Sketchup::Face).select {|x| Labeler.window?(x)}
			end

			# Gets all the solved workplanes in the model
			# @author German Molina			
			# @return [Array <SketchUp::Entities>] An array with the entities that are SketchUp::ComponentDefinition
			def self.get_solved_workplanes()
				Sketchup.active_model.definitions.select{|x| 
					Labeler.solved_workplane?(x)
				}.map{|x|
					x.instances
				}.flatten
			end
			
			# Hides or show a specific label.
			# Shows class if hidden, hides class if shown. All according to the
			# first face that is part of the class
			# @author German Molina
			# @param label [String] the label to hide/show
			# @return [Void]
			def self.hide_show_specific(label)
				entities=Sketchup.active_model.entities
				entities = entities.select{|x| Labeler.get_label(x) == label }

				Sketchup.active_model.definitions.each{|defi|
					entities += defi.entities.select{|x| Labeler.get_label(x) == label }
				}

				return if entities.length == 0

				hide = true
				hide = false if entities[0].hidden?
				op_name = "Hide/Show Specific"
				begin
					model=Sketchup.active_model
					model.start_operation( op_name ,true)
					entities.map{|x|
						x.hidden = hide
						edges = []
						edges = x.edges if x.class.method_defined? :edges
						edges.map{|y| y.hidden = hide}
					}
					model.commit_operation
				rescue Exception => ex
					UI.messagebox ex
					model.abort_operation
					raise ex
				end
			end



        end
    end
end