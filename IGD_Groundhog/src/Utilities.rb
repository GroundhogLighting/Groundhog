module IGD
	module Groundhog
		# This class contains the methods that are useful other methods.
		#
		# For example, obtain all the faces within an array, or all the windows, or delete all the
		# entities with a certain label.
		module Utilities


			def self.mat_array_2_mat_string(mat_array,name)
				ret=""
				mat_array.uniq!
				extension=""
				extension= "_"+name if name
				mat_array.each do |mat|
					ret+=Exporter.get_mat_string(mat, Utilities.fix_name(mat.name)+extension)+"\n\n"
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
				return "document.getElementById('#{id}').value='#{value}';"
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
=begin
			# Reverse all the faces in an array
			# @author German Molina
			# @param entities [Array<entities>] Array of entities
			# @return [Void]
			def self.reverseFaces(entities)
				faces=self.get_faces(entities)

				faces.each do |k|
					if Labeler.face?(k)
						k.reverse!
					end
				end
			end
=end

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
					end

					model.commit_operation
				rescue Exception => ex
					UI.messagebox ex
					model.abort_operation
				end

			end

			# Get the Window Groups of the windows within an array.
			# @author German Molina
			# @param entities [Array<entities>] Array of entities
			# @return [Array <Int>] Array with the unique window groups
			def self.get_win_groups(entities)
				groups=[]
				windows=self.get_windows(entities)
				windows.each do |i|
					a=Labeler.get_win_group(i)
					if a!=nil
						groups=groups+[a]
					end
				end

				return groups.uniq
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

				badvert=0
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
				return entities.select{|x| Labeler.workplane? x}
			end

			# Gets the workplanes
			# @author German Molina
			# @param entities [Array<SketchUp::Entities>]
			# @return [Array <SketchUp::Entities>] An array with the entities that are SketchUp::ComponentDefinition
			def self.get_solved_workplanes(entities)
				return entities.select{|x| Labeler.solved_workplane? x}
			end

			# Returns an array with the transformations that lead to the global position of the entity
			# @author German Molina
			# @param entity [SketchUp::Entities]
			# @return [Array <SketchUp::Transformation>] An array with the transformations
			# @note This method is not used, and it is not working... the idea was to enable
			#    exporting illums and workplanes within groups and components, but I could not
			#    find a way of geting the global coordinates of them.
			def self.get_global_transformations(entity)
				tr=[]
				if entity.is_a? Sketchup::Face
					until entity.parent.is_a? Sketchup::Model
						tr << entity.parent.transformation
						entity = entity.parent
					end
				else
					until entity.is_a? Sketchup::Model
						tr << entity.transformation
						entity = entity.parent
					end
				end
			end

			# Hides all solved workplanes with the exception of those with the input metric
			# @author German Molina
			# @param metric [String]
			# @version 0.1
			def self.remark_solved_workplanes(metric)
				#hide them all, except those with the metric we are interested in
				scale_min=false
				scale_max=false
				self.get_solved_workplanes(Sketchup.active_model.entities).each{|x|
					value=JSON.parse(Labeler.get_value(x))
					if value["metric"]==metric
						x.hidden=false
					else
						x.hidden=true
					end
				}
			end


		end
	end #end module
end
