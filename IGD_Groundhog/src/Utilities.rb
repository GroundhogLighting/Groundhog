module IGD
	module Groundhog

		# This modiule contains the methods that are useful other methods.
		#
		# For example, obtain all the faces within an array, or all the windows, or delete all the
		# entities with a certain label.
		module Utilities

			# Returns the workplane that has a certain name
			#
			# @author German Molina
			# @return [SketchUp::Face] The workplane
			# @param wp_name [String] The name of the workplane
			def self.get_workplane_by_name(wp_name)
				wp = Utilities.get_workplanes(Sketchup.active_model.entities).select{|x| Labeler.get_name(x)==wp_name}
				UI.messagebox "Two or more objectives have the same name... Only one of them will be processed.\nThis is something you should fix." if wp.length > 1
        return wp.shift
			end

			# Compares a two version strings in format "A.B.C"
			#
			# If they are the same, it returns 0... if the first one is older,
			# returns 1; if the first one is newer, returns -1.
			# @author German Molina
			# @return [Integer] The number.
			# @param older [String] A version number in string format (A.B.C)
			# @param newer [String] A version number in string format (A.B.C)
			def self.compare_versions(older,newer)
				return 0 if older == newer

				older = older.split(".").map{|x| x.to_i}
				newer = newer.split(".").map{|x| x.to_i}
				3.times { return -1 if newer.shift < older.shift}
				return 1
			end

			#  Assess the current CIE sky, using model's sun position and
			#  a type of sky
			#
			# @author German Molina
			# @return [String] The sky description
			# @param sky_type [String] The sky type
			def self.get_current_sky(sky_type)
				sky = false
				info=Sketchup.active_model.shadow_info
				sun=info["SunDirection"]
				floor=Geom::Vector3d.new(sun.x, sun.y, 0)
				alt=sun.angle_between(floor).radians
				azi=floor.angle_between(Geom::Vector3d.new(0,-1,0)).radians
				azi=-azi if sun.x>0
				if alt >= 3 then
					sky="gensky -ang #{alt} #{azi} #{sky_type} -g #{Config.albedo}"
				end
				return sky
			end

			def self.mat_array_2_mat_string(mat_array,name)
				ret=""
				mat_array.uniq!
				extension=""
				extension= "_"+name if name
				mat_array.each do |mat|
					ret+=Materials.get_mat_string(mat, self.fix_name(mat.name)+extension, false)+"\n\n"
				end
				return ret
			end


			#  Loads a text file (CSV, TSV) into an array of strings.
			#
			# @author German Molina
			# @return [<String>] Array of the items
			# @param file [String] The file to read
			# @param del [String] the Delimiter
			# @param headers [Integer] the number of rows to skip
			# @version 0.1
			def self.readTextFile(file,del,headers)
				if not File.exist?(file) then
					UI.messagebox("File to read not found when trying to 'loadTextFile'.")
					return false
				end

				file = File.open(file, "r").read.squeeze("\n").squeeze("\r\n").lines
				headers.times do
					file.shift
				end

				ret=[]
				file.each do |line|
					data = line.strip.split(del)
					return ret if line == []
					ret.push(data)
				end
				return ret
			end

			# returns a piece of javascript script (String) that would set the value of
			#  a certain element in the html in the WebDialog.
			#  The names of the fields are the UPPERCASE id.
			#  If there is no hash['ID'] value, or it is empty, the default value will be used.
			#
			# @author German Molina
			# @return [String] the piece of javascript code
			# @param id [String] the id of the element in the webdialog to set the value
			# @param hash [Hash] the hash where the values are stored.
			# @param default [value] the default value used
			# @version 0.1
			def self.set_element_value(id, hash, default)
				value = hash[id.upcase]

				if value == "" or value == nil then
					#use default if not nil
					if default == nil then
						return " "
					else
						value = default
					end
				end
				return "preferencesModule.set_element_value('#{id}','#{value}');"
			end

			# Fix the name, eliminating complex symbols
			# @author German Molina
			# @param name [String] The name to fix
			# @return [String] The fixed name
			def self.fix_name(name)
				return name.tr(" ","_").tr("#","_")
			end


			# Ask the user for a name
			# @author German Molina
			# @return [String] The asigned name
			def self.get_name
				name = UI.inputbox ["Name\n"], [""], "Assign a name"
				return false if not name
				return name[0]
			end

			# Returns all the Sketchup::Face within an array.
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>] Array with entities.
			# @return [Array<Sketchup::Faces>] An array of faces.
			def self.get_faces(entities)
				return entities.select {|x| x.is_a? Sketchup::Face }
			end

			# Sets of entities to be exported contain groups or faces or component definitions.
			# This method tells us if the entities passed as arguments have those or not.
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>] Array with entities.
			# @return [Boolean] The answer
			def self.has_relevant_content?(entities)
				groups = entities.select{|x| x.is_a? Sketchup::Group}.length
				faces = self.get_faces(entities).length
				comps = entities.select{|x| x.is_a? Sketchup::ComponentInstance}.length
				(groups+faces+comps) > 0
			end

			# Returns all the Sketchup::Group within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Sketchup::Faces] An array of faces.
			def self.get_groups(entities)
				ret=[]
				entities.each do |k|
					if Labeler.group?(k) then
						ret=ret+[k]
					end
				end
				return ret
			end

			# Returns all the Sketchup::Group within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Sketchup::Faces] An array of faces.
			def self.get_images(entities)
				ret=[]
				entities.each do |k|
					if Labeler.image?(k) then
						ret=ret+[k]
					end
				end
				return ret
			end

			# Returns all the windows within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Array<faces>] An array of faces.
			def self.get_windows(entities)
				return entities.select {|x| Labeler.window?(x)}
			end


			# Deletes all the entities with a certain Label.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Void]
			def self.delete_label(entities, label)
				labeled=0
				entities.each do |ent|
					if not ent.deleted?
						if ent.get_attribute("Groundhog","Label")==label then
							ent.erase!
							labeled=labeled+1
						end
					end
				end
				# if, for some reason, there are some left, try again... it happened.
				if labeled!=0 then
					delete_label(entities,label)
				end
			end

			# Count the windows within an array
			# @author German Molina
			# @param entities [Array<entities>] Array of entities
			# @return [Int] Number of windows.
			def self.count_windows(entities)
				return self.get_windows(entities).length
			end


			# Checks if all the windows within a set of entities have the same normal (point to the same direction).
			# @author German Molina
			# @param entities [Array<entities>] Array of entities
			# @return [Boolean]
			def self.check_window_normals(entities)
				windows=self.get_windows(entities)
				normal=windows[0].normal

				windows.each do |win| #I know... it will check with itself as well.
					if win.normal!=normal then #in the first non-equal normal, it will return false.
						return false
					end
				end

				return true
			end


			# Assigns the same "Groundhog","Win_Group" attribute to a set of windows.
			# @author German Molina
			# @param entities [Array <entities>] Array of entities
			# @param g [String] Name of the group
			# @return [Void]
			# @note The number does not actually matter... it comes from the Main "Groundhog.rb" file.
			# @todo Maybe create a better/more-formal way of doing this? new class?
			def self.group_windows(entities,g)

				begin
					model=Sketchup.active_model
					op_name="Group Windows"
					model.start_operation( op_name,true )

					windows=self.get_windows(entities)
					if self.check_window_normals(windows) then #if they all have the same normal, then
						windows.each do |entity|
							entity.set_attribute("Groundhog","Win_Group",g)
						end
					else
						UI.messagebox("All selected windows must have the same normal")
						model.abort_operation
					end

					model.commit_operation
				rescue Exception => ex
					UI.messagebox ex
					model.abort_operation
					raise ex
				end

			end

			# Get the Window Groups of the windows within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array of entities
			# @return [Array <Int>] Array with the unique window groups
			def self.get_win_groups(entities)
				windows=self.get_windows(entities).select{|x| Labeler.get_win_group(x) != nil}
				windows.map{|x| Labeler.get_win_group(x)}.uniq
			end




			# Checks if the face is planar. For some reason some faces were recognized in Radiance as non-planars when building the octree.
			# @author German Molina
			# @param face [Sketchup::Face] the face
			# @return [Boolean] True if true, False if false.
			# @note This method was adapted from the Radiance Source Code, in "face.c". I wanted Radiance and Groundhog to agree on this
			def self.planar?(face)
				vertices=face.vertices
				return true if vertices.length<=3

				# This section is from Radiance source code.
				v1=vertices[1].position.-vertices[0].position
				norm=Geom::Vector3d.new
				for i in 2..vertices.length-1
					v2=vertices[i].position.-vertices[0].position
					v3=v1.cross(v2)
					norm=norm.+(v3)
				end

				offset=norm.dot(Geom::Vector3d.new(vertices[0].position.x,vertices[0].position.y,vertices[0].position.z))
				verteps=0.0000015
				smalloff=offset.abs <= verteps

				for i in 1..vertices.length-1
					d1=norm.dot(Geom::Vector3d.new(vertices[i].position.x,vertices[i].position.y,vertices[i].position.z))
					if smalloff then
						tmp=d1-offset/i
					else
						tmp=1.0-d1*i/offset
					end

					return false if tmp.abs > verteps

					offset+=d1
				end

				return true
			end

			# Hides or show a specific label.
			# Shows class if hidden, hides class if shown. All according to the
			# first face that is part of the class
			# @author German Molina
			# @param label [String] the label to hide/show
			# @return [Void]
			def self.hide_show_specific(label)
				entities=Sketchup.active_model.entities
				entities = entities.select{|x| Labeler.is?(x,label)}

				Sketchup.active_model.definitions.each{|defi|
					entities += defi.entities.select{|x| Labeler.is?(x,label)}
				}

				return if entities.length == 0

				hide=true
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


			# Returns an array of horizontal faces in the model.
			# @author German Molina
			# @param entities [Array<entities>] Array with entities.
			# @return [Sketchup::Faces] An array of faces.
			def self.get_horizontal_faces(entities)
				return entities.select{ |x| Labeler.face?(x) and self.is_horizontal?(x)}
			end

			# Returns a boolean telling if a face is horizontal or not.
			# @author German Molina
			# @param entity
			# @return boolean
			def self.is_horizontal?(entity)
				entity.is_a? Sketchup::Face and entity.normal.parallel?(Geom::Vector3d.new(0,0,1))
			end

			# Gets the component instances from a set of entities
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::ComponentInstances>] An array with the component instances
			def self.get_component_instances(entities)
				return entities.select{|x| x.is_a? Sketchup::ComponentInstance or x.is_a? Sketchup::Group}
			end

			# Tells if a Sketchup::Entity can be assigned a name.
			# @author German Molina
			# @param entity [Array<SketchUp::Entities>]
			# @return [Boolean]
			def self.namable?(entity)
				entity.is_a? Sketchup::ComponentInstance or entity.is_a? Sketchup::Group or entity.is_a? Sketchup::Face
			end

			# Gets the entities in an array that can be named
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that can be named
			def self.get_namables(entities)
				return entities.select{|x| self.namable?(x)}
			end

			# Gets the entities in an array that are SketchUp::ComponentDefinition
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that are SketchUp::ComponentDefinition
			def self.get_components(entities)
				return entities.select{|x| x.is_a? Sketchup::ComponentInstance}
			end



			# Gets the workplanes
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that are SketchUp::ComponentDefinition
			def self.get_workplanes(entities)
				return entities.select{|x| Labeler.get_label(x)=="workplane"}
			end

			# Gets the workplanes
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that are SketchUp::ComponentDefinition
			def self.get_solved_workplanes(entities)
				return entities.select{|x| Labeler.solved_workplane?(x)}
			end


			# Hides all solved workplanes with the exception of those with the input metric
			# @author German Molina
			# @param objective [String] The name of the objective to remark
			# @version 0.1
			def self.remark_solved_workplanes(objective)
				#hide them all, except those with the metric we are interested in
				self.get_solved_workplanes(Sketchup.active_model.entities).each{|x|
					value=JSON.parse(Labeler.get_value(x))
					if value["objective"]==objective
						x.hidden=false
					else
						x.hidden=true
					end
				}
			end

			# Returns an array with the transformations that lead to the global position of the entity
			# @author German Molina
			# @param entity [SketchUp::Face (or something)]
			# @return [Array <SketchUp::Transformation>] An array with the transformations
			# @note if the input entity is not within a group or component, its own transformation will be returned.
			def self.get_all_global_transformations(entity,transform)
				ret = []
				if entity.parent.is_a? Sketchup::Model then
					ret << transform if not entity.respond_to? :transformation #face, edge, or other
					ret << transform * entity.transformation if entity.respond_to? :transformation #if it is a Component instance or group
				else
					entity.parent.instances.each{|inst|
						ret += get_all_global_transformations(inst,transform)
					}
				end
				return ret
			end

			# Receives a SketchUp::Face (will be verified), checks if it is a circle and returns the radius of the circle.
			# A circle is defined as a polygon with more than N vertices (check code for that number) at the same distance to
			# its center.
			# @author German Molina
			# @param face [SketchUp::Face (or something)]
			# @return [Float] The Radius... false if input is not a circle.
			def self.get_circle_radius(face)
				return false if not face.is_a? Sketchup::Face
				return false if face.loops.length != 1
				vertices = face.vertices
				return false if vertices.count < 15 #is this enough vertices to be a circle?

				center = face.bounds.center

				radius = center.distance vertices.shift
				vertices.each{|v|
					r = center.distance v.position
					return false if (r-radius).abs > 1e-3
				}
				return radius
			end


		end # end module
	end #end module
end
