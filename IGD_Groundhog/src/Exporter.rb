module IGD
	module Groundhog

		# This module has the methods that allow exporting the SketchUp model.
		module Exporter

			# Gets the path where the SketchUp model is saved. If it is not saved, it will return false.
			# @author German Molina
			# @version 1.0
			# @return [String] Path where the model is saved.
			# @example Get the path
			#   path=Exporter.getpath
			def self.getpath
				model=Sketchup.active_model
				path=model.path
				return false if path=="" #model has not been saved

				path=path.tr("\\","/") #normalize Windows paths into Ruby paths (with /)
				path=path.split("/")
				path.pop #drop the name of the file
				return File.join(path)
			end


			# Returns the front-material of the face, if it has one. If not, it will return
			# the back one. If it does not have one of those either, it will return the
			# default ones.
			# @author German Molina
			# @version 1.0
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @return [Sketchup::Material] The material
			def self.get_material(face)
				mat=face.material
				if mat==nil then # If the face does not have a front material
					mat=face.back_material # the back material will be tested
				end
				if mat==nil then # If it does not have a Back material either
					if Labeler.window?(face) then #defaults are assigned
						mat=Sketchup.active_model.materials[Materials.default_glass["name"]] #If it is a glass
						if mat==nil #this means the materials has been deleted or are not there yet.
							Materials.add_default_glass
							mat=Sketchup.active_model.materials[Materials.default_glass["name"]] #If it is a glass
						end
					else
						mat=Sketchup.active_model.materials[Materials.default_material["name"]] #if it is anything else (Illums and Workplanes will be ignored later)
						if mat==nil #material deleted
							Materials.add_default_material
							mat=Sketchup.active_model.materials[Materials.default_material["name"]] #if it is anything else (Illums and Workplanes will be ignored later)
						end
					end
				end
				return mat
			end

			# Assess the array of vertex that conform the face, closing it as Radiance needs.
			#
			# @author German Molina
			# @version 1.0
			# @param face [Sketchup::Face] SketchUp face
			# @return [<Array>] Of SketchUp 3DPoints
			def self.get_vertex_positions(face)
				radius = Utilities.get_circle_radius(face)
				ret = []
				if not radius then
					if face.loops.count > Config.max_loops then #triangulate
						mesh = face.mesh
						points = mesh.points
						mesh.polygons.each{|polygon|
							ret << polygon.map{|x| points[x.abs-1]}
						}
					else #close it and export it
						ret << self.close_face_2(face)
					end
				else #it is a circle
					normal = face.normal
					normal.length=radius
					center = face.bounds.center
					ret << [center, normal] #any vertex positions returned with 2 items is a circle... the items are [Center,Normal]
				end
				return ret
			end

			# Assess the String that should be written in the Radiance geometry file from an array of 3D Points
			# @author German Molina
			# @version 1.0
			# @param positions_list [Array of Sketchup::3DPoint] An array of Arrays of 3D Points
			# @return [String] The string to be written in the .rad file
			def self.vertex_positions_to_rad_string(positions_list,name)
				ret = ""
				positions_list.each {|positions|
					string1=""
					string2=""
					if positions.length == 2 then #a circle
						string1="%MAT_NAME%\tring\t"+name+"\n0\n0\n8\n" #Write the standard first three lines
						center = positions.shift
						normal = positions.shift
						radius = normal.length
						normal.normalize!
						string2="\t#{center.x.to_m} #{center.y.to_m} #{center.z.to_m}\n\t#{normal.x} #{normal.y} #{normal.z}\n\t0 #{radius.to_m}\n"
					elsif positions.length >= 3 #a polygon
						string1="%MAT_NAME%\tpolygon\t"+name+"\n0\n0\n"+(3*positions.length).to_s #Write the standard first three lines
						string2=""
						positions.each{|pos|
							string2=string2+"\t#{pos.x.to_m.to_f}\t#{pos.y.to_m.to_f}\t#{pos.z.to_m.to_f}\n"
						}
						string2+="\n\n"
					else #something weird
						raise "Error! trying to get the rad string of a polygon with less than 3 vertices."
					end
					ret += string1
					ret += string2
				}

				return ret
			end

			# Assess the String that should be written in the Radiance geometry file.
			#
			# If no material is assigned, or the material is not supported, it assigns one of the
			# default materials.
			# @author German Molina
			# @version 1.3
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @return [<Array>] The string to be written in the .rad file, and the material
			def self.get_rad_string(face)
				return false if face.deleted? #return false if the face does not exist any more.
				return false if not face
				mat = self.get_material(face)
				positions = self.get_vertex_positions(face)
				name = Labeler.get_fixed_name(face)
				return false if not name
				return [self.vertex_positions_to_rad_string(positions,name),mat] #Returns the string and the material
			end

			# Same as get_rad_string, but transforming the vertices.
			# @author German Molina
			# @version 1.0
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @param transformation [Geom::Transformation] SketchUp transformation to apply to the vertices
			# @param name [String] A String with the name to asign to the face
			# @return [<Array>] The string to be written in the .rad file, and the material
			def self.get_transformed_rad_string(face,transformation,name)
				mat = self.get_material(face)
				positions = self.get_vertex_positions(face).map{|x| x.map{|y| y.transform(transformation)}}
				name = Utilities.fix_name(name)
				return [self.vertex_positions_to_rad_string(positions,name),mat] #Returns the string and the material
			end


			# Same as get_rad_string, but transforming the vertices and reversing the face
			# @author German Molina
			# @version 1.0
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @param transformation [Geom::Transformation] SketchUp transformation to apply to the vertices
			# @param name [String] A String with the name to asign to the face
			# @return [<Array>] The string to be written in the .rad file, and the material
			def self.get_reversed_transformed_rad_string(face,transformation,name)
				mat = self.get_material(face)
				positions = self.get_vertex_positions(face).reverse.map{|x| x.map{|y| y.transform(transformation) }}
				name = Utilities.fix_name(name)
				return [self.vertex_positions_to_rad_string(positions,name),mat] #Returns the string and the material
			end


			# Same as get_rad_string, but reversing the order of the vertices.
			# @author German Molina
			# @version 1.3
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @return [<Array>] The string to be written in the .rad file, and the material
			def self.get_reversed_rad_string(face)
				mat = self.get_material(face)
				positions = self.get_vertex_positions(face).map{|x| x.reverse}
				name = Labeler.get_fixed_name(face)
				return [self.vertex_positions_to_rad_string(positions,name),mat] #Returns the string and the material
			end

			# Removes all the vertex that are
			# @param face [Array<Point3D>] The face in Point3D format
			# @example  face = face.vertices.map{|x| x.position}
			#     clean_face(face)
			# @note It is assumed that the face does not have any interior
			#     loops. It can be closed by using the close_face_2 method
			def self.clean_face(face)
				ret = [face.shift]
				face << ret[0] # add it at the end... so we can close the loop
				while face.length > 1 do
					pt = face.shift
					dir1 = ret[-1].vector_to(pt)
					dir2 = pt.vector_to(face[0])
					if not dir1.parallel? dir2 then
						ret << pt
					end
				end
				return ret
			end


			# Recursively connects the interior and the exterior loops of a face, without
			# adding any new line or loop to the model
			#
			# This allow efficient exporting by exporting only One Radiance polygon for each SketchUp face.
			#
			# This method exists because SketchUp allows interior loops, but Radiance does not.
			#
			# This method is called within #get_rad_string, and returns an array with the
			# Sketchup::Point3d representing the vertices in the correct order
			# @author German Molina
			# @param face [face] SketchUp face to close.
			# @return [Array] An array with the Sketchup::Point3d representing the vertices in the correct order
			def self.close_face_2(face)
				outer_loop = face.outer_loop.vertices.map{|x| x.position}
				inner_loops = face.loops.select{|x| not x.outer?}.map{|x| x.vertices.map{|y| y.position}}

				until inner_loops.count == 0 do
					#find the minimum distance from interior to exterior
					min_distance = 1e9
					min_inner_loop = false
					min_ext_vertex = false
					min_inner_vertex=false
					outer_loop.each{|ext_vertex|
						inner_loops.each{|inner_loop|
							inner_loop.each{|inner_vertex|
								distance = ext_vertex.distance(inner_vertex)
								if distance < min_distance then
									min_distance = distance
									min_ext_vertex = ext_vertex
									min_inner_vertex = inner_vertex
									min_inner_loop=inner_loop
								end
							}
						}
					}
					# pass the inner loop to the exterior loop
					# (check normal --> order of the vertices)... it seems that is not required.
					aux_ret = []
					outer_loop.each{|ext_vertex|
						aux_ret << ext_vertex
						if ext_vertex == min_ext_vertex then
							#add the loop
							i = min_inner_loop.index(min_inner_vertex) #start from here
							raise "min_inner_vertex not found during Close_face" if i == nil
							min_inner_loop.length.times{
								aux_ret << min_inner_loop[(i+=1)%min_inner_loop.length - 1]
							}
							aux_ret << min_inner_vertex #add the first vertex again
							aux_ret << ext_vertex #return to the exterior loop
						end
					}
					outer_loop = aux_ret

					#erase the inner loop from the list
					inner_loops.delete(min_inner_loop)
				end				
				return outer_loop
			end


			# Export the entire model to the path where the model is saved.
			#
			# Each layer is exported on a different file with the name of the layer, and the
			# "illums" of each layer are also exported on a separate file. To make a different organization,
			# #exportFaces method should be modified.
			# @author German Molina
			# @version 1.0
			# @param path [String] The path where the model will be exported
			# @return [Boolean] Success
			def self.export(path)
				model = Sketchup.active_model
				OS.clear_path(path)
				begin
					op_name="Export"
					model.start_operation(op_name,true)

					FileUtils.cd(path) do
						#Export the faces and obtain the modifiers
						mod_list=self.export_layers
						mod_list.uniq!
						return false if not mod_list
						return false if not self.export_modifiers(mod_list)
						return false if not self.write_sky
						return false if not self.write_weather
						return false if not self.export_views
						return false if not self.export_component_definitions
						return false if not self.write_photosensors
						return false if not self.write_scene_file
						return false if not self.write_workplanes

						Sketchup.active_model.materials.remove(Sketchup.active_model.materials["GH_default_material"])
					end
					model.commit_operation
				rescue Exception => ex
					model.abort_operation
					FileUtils.rm_rf(path, secure: true)
					UI.messagebox ex
					raise ex
				end
				return true
			end

			# Writes the weather file in WEA format
			# @author German Molina
			# @version 2.0
			# @return [Boolean] Success
			def self.write_weather
				path = "./Skies"
				weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
				return true if weather == nil
				OS.mkdir(path)
				weather = JSON.parse(weather)
				Weather.write_wea(weather,1,12,"#{path}/weather.wea")
			end


			# This method exports the faces organized in Groundhog distribution
			#
			# Each layer will be exported on on a different file, as well as each illum of each layer.
			#
			# @author German Molina
			# @version 1.0.5
			# @return [Array<Material>] Array of all the unique materials assigned to the exported faces.
			# @return false if not succss or cancelled
			# @example Export the whole model.
			def self.export_layers

				path = "./Geometry"
				OS.mkdir(path)

				mat_list=[] #This will store the modifiers (materials) of each face.
				model=Sketchup.active_model
				entities=model.entities

				faces=Utilities.get_faces(entities)

				windows=[] # this array will store the windows in case their are needed
				illums=[]

				#We get the layers in the model
				layers=model.layers
				#we open one file per each layer
				writers=Hash.new #this is an array of writers
				layers.each do |layer|
					writers[layer.name] = File.open("#{path}/#{Utilities.fix_name(layer.name)}.rad",'w+')
				end


				#now we loop over the faces, and write them were they belong
				faces.each do |fc| #for each face
					next if fc.deleted?
					info=self.get_rad_string(fc) #get the information
					next if not info # ignore if the face was deleted

					if Labeler.window?(fc)
						#Window groups will be exported separatedly
						windows=windows+[fc]
					elsif Labeler.workplane?(fc) then
						next # These will be exported later
					elsif Labeler.illum?(fc) then
						illums=illums+[fc]
					else
						#write the information
						writers[fc.layer.name].puts info[0].gsub("%MAT_NAME%",Utilities.fix_name(info[1].name))
						#store the material
						mat_list=mat_list+[info[1]]
					end #end of check the label of the face
				end #end for each faces

				#Close the rest of the files
				writers.each do |name,file|
					file.close
				end

				#Write windows
				return false if not self.write_window_groups(windows)

				#Write illums
				return false if not self.write_illums(illums)

				#write rif
				return false if not self.write_rif_file(illums, windows)

				return mat_list
			end

			# Get the String that describes a view from a certain SketchUp camera in Radiance format.
			# @author German Molina
			# @version 0.2
			# @param camera [Camera] A SketchUp Camera object
			# @return [String]
			# @example Export the actual view
			#   File.open("/Certain/Directory/view.vf",'w'){|f|
			#		f.write(self.get_view_string(Sketchup.active_model.active_view.camera))
			#	}
			# @todo This is not a good method actually... there are much more options for views on Radiance.
			#   some work should be done here in order to get it working correctly.
			def self.get_view_string(camera)
				vp=camera.eye
				vd=camera.direction
				vu=camera.up
				vh=0
				vv=0
				vt=""
				if camera.perspective? then
					fov=camera.fov
					vh=2*fov
					vv=fov #Not sure how to calculate this
					vt="vtv"

				else
					vv=camera.height.to_m
					vh=2*vv #Not sure how to calculate this
					vt="vtl"
				end

				return "rvu -#{vt} -vp #{vp.x.to_m.to_f} #{vp.y.to_m.to_f} #{vp.z.to_m.to_f} -vd #{vd.x} #{vd.y} #{vd.z} -vu #{vu.x} #{vu.y} #{vu.z} -vh #{vh} -vv #{vv}"
			end

			# Exports the actual view in a "view.vf" file, and al the scenes (called pages, within the API) in other files
			# with the scene (page)name.
			# @author German Molina
			# @version 0.3
			# @return [Boolean] Success
			def self.export_views

				path="./Views"
				OS.mkdir(path)

				#Export the actual view
				File.open("#{path}/view.vf",'w+'){|f|
					f.puts(self.get_view_string(Sketchup.active_model.active_view.camera))
				}
				#then the scenes
				pages=Sketchup.active_model.pages
				if pages.count>=1 then
					pages.each do |page|
						File.open("#{path}/#{Utilities.fix_name(page.name)}.vf",'w+'){|f|
							f.puts(self.get_view_string(page.camera))
						}
					end
				end
				return true

			end

			# Export the window groups. This method is called from #exportFaces. Creates a Window folder within the directory.
			# @author German Molina
			# @version 1.1
			# @param windows [faces] An array with windows, selected during #exportFaces.
			# @return [Boolean] Success
			# @note This only works well when you export windows within the same group! (or wild in the model).
			def self.write_window_groups(windows)

				return true if windows.length <= 0 #it did success... but there were not any windows
				not_in_component = windows[0].parent.is_a? Sketchup::Model

				path = "./Windows"
				OS.mkdir(path)
				groups=Utilities.get_win_groups(windows)

				wins = false
				if not_in_component then
					wins = File.open("#{path}/windows.rad",'w')
				else
					wins = File.open("#{path}/windows.rad",'a')
				end

				tr = Utilities.get_all_global_transformations(windows[0],Geom::Transformation.new)
				tr.each_with_index{|t,index|
					#Write the windows that have a group
					groups.each{|group|
						file_name = "#{Labeler.get_fixed_name(windows[0].parent)}_#{Utilities.fix_name(group)}_#{index}" if not not_in_component
						file_name = "#{Utilities.fix_name(group)}" if not_in_component
						group_path = "#{path}/#{file_name}.wingroup"
						wins.puts "!xform ./Windows/#{file_name}.wingroup"
						group_file =  File.open(group_path,'w')
						windows.select{|x| Labeler.get_win_group(x) == group}.each {|win|
							win_name = "#{Labeler.get_fixed_name(win)}_#{index}"
							win_name = "#{Labeler.get_fixed_name(win)}" if not_in_component
							info = Exporter.get_transformed_rad_string(win,t,win_name)
							group_file.puts Materials.get_mat_string(info[1],"#{Labeler.get_name(win)}_mat",false)
							group_file.puts info[0].gsub("%MAT_NAME%","#{Labeler.get_name(win)}_mat ")
						}
						group_file.close
					}

					windows.select{|x| Labeler.get_win_group(x) == nil}.each {|win|
						file_name = "#{Labeler.get_fixed_name(win)}"
						file_name = "#{Labeler.get_fixed_name(windows[0].parent)}_#{Labeler.get_fixed_name(win)}_#{index}" if !not_in_component
						group_path = "#{path}/#{file_name}.wingroup"
						wins.puts "!xform ./Windows/#{file_name}.wingroup"
						group_file =  File.open(group_path,'w')
						win_name = "#{Labeler.get_fixed_name(win)}_#{index}"
						win_name = "#{Labeler.get_fixed_name(win)}" if not_in_component
						info = Exporter.get_transformed_rad_string(win,t,win_name)
						group_file.puts Materials.get_mat_string(info[1],"#{Labeler.get_name(win)}_mat",false)
						group_file.puts info[0].gsub("%MAT_NAME%","#{Labeler.get_name(win)}_mat ")
						group_file.close

					}
				}


				wins.close
				return true

			end

			# Writes the workplanes in the model (need to be in the model, not in components)
			#
			# @author German Molina
			# @return [Boolean] Success
			def self.write_workplanes
				workplanes = Utilities.get_workplanes(Sketchup.active_model.entities)
				return true if workplanes.length == 0 #success... just, no workplanes.
				wp_names = workplanes.map{|x| Labeler.get_name(x) }.uniq
				path = "./Workplanes"
				OS.mkdir(path)

				wp_names.each{|workplane|
					name=Utilities.fix_name(workplane)

					pixels_file = File.open("#{path}/#{name}.pxl",'w+')
					points_file = File.open("#{path}/#{name}.pts",'w+')
					wp_group = workplanes.select{|x| IGD::Groundhog::Labeler.get_name(x) == workplane}
					wp_group.each{|face|
						#CLEAN AND CLOSE AND ALL.
						#aux_face = self.close_face_2(face)						
						#aux_face = self.clean_face(aux_face)
						# Unfortunately, until we have a triangulation algorithm,
						# I have to add the face, get the mesh, and then delete it
						#aux_face = Sketchup.active_model.entities.add_face(aux_face)
						mesh = face.mesh 4
						#Sketchup.active_model.entities.erase_entities(aux_face)

						# Go on as usual.
						points = mesh.points
						polygons = mesh.polygons
						normals = polygons.each_with_index.map{|p,i| mesh.normal_at(i+1)}
						# Work one of the received polygons at a time
						polygons.each_with_index{|polygon, index|
							triangles = Triangle.triangulate(points,[polygon])
							#normal = mesh.normal_at(index+1)
							normal = normals[index]
							triangles.each { |triangle|
								pos = Triangle.get_center(triangle)
								#warn pos.inspect
								pixels_file.puts "#{triangle[0].x.to_m},#{triangle[0].y.to_m},#{triangle[0].z.to_m},#{triangle[1].x.to_m},#{triangle[1].y.to_m},#{triangle[1].z.to_m},#{triangle[2].x.to_m},#{triangle[2].y.to_m},#{triangle[2].z.to_m}"
								points_file.puts "#{pos.x.to_m}\t#{pos.y.to_m}\t#{pos.z.to_m}\t#{normal.x}\t#{normal.y}\t#{normal.z}"
							}
						}
					} # ed of wp_group.each

					pixels_file.close
					points_file.close
				} # end wp_names.each

				return true
			end


			# Exports illum surfaces
			# @author German Molina
			# @version 1.0
			# @param entities [Array <Sketchup::Face>] An array with illums, selected during exportFaces.
			# @return [Boolean] Success
			def self.write_illums(entities)

				return true if entities.length<1  #success... did not export, though.

				path="./Illums"
				OS.mkdir(path)

				entities.each do |ent| #for all the entities (which are faces)
					next if ent.deleted?
					if Labeler.illum?(ent) then #Only illums
						name=Labeler.get_fixed_name(ent) #Get the name of the surface
						info=self.get_rad_string(ent)
						next if not info # ignore if the ent does not exist anymore
						File.open("#{path}/#{name}.rad",'w+'){ |f| #The file is opened
							f.puts(info[0].gsub("%MAT_NAME%","void"))
						}

					end
				end

				return true
			end


			# Export the Radiance Modifiers
			# @author German Molina
			# @version 1.0
			# @param mat_array [faces] An array with the materials to export
			# @return [Boolean] Success
			def self.export_modifiers(mat_array)
				path = "./Materials"
				OS.mkdir(path)
				File.open("#{path}/materials.mat",'w+'){ |f| #The file is opened
					mat_array.each do |mat|
						mat_string = Materials.get_mat_string(mat,false, true)
						return false if not mat_string
						f.puts(mat_string)
					end
				}
				return true
			end


			# Export the Scene file. The Scene file references the different Radiance files to create the model.
			# @author German Molina
			# @version 0.9
			# @return [Boolean] success
			def self.write_scene_file
				File.open("./scene.rad",'w+'){ |f| #The file is opened
					f.puts("###############\n## Scene exported using Groundhog v"+Sketchup.extensions["Groundhog"].version.to_s+" from SketchUp "+Sketchup.version+"\n## Date of export: "+Time.now.to_s+"\n###############\n")

					f.puts("\n\n\n###### GEOMETRY \n\n")

					Sketchup.active_model.layers.each do |layer|
						name=layer.name.tr(" ","_")
						f.puts("!xform ./Geometry/"+name+".rad\n")
					end

					f.write("\n\n\n###### GROUND \n\n")
					if Config.add_terrain == true then
						albedo = Config.albedo
						model_bounds=Sketchup.active_model.bounds
						radius = IGD::Groundhog::Config.terrain_oversize * model_bounds.diagonal
						f.puts("void plastic terrain_mat\n0\n0\n5\t#{albedo}\t#{albedo}\t#{albedo}\t0\t0")
						f.puts("\n\nterrain_mat ring ground 0 0 8 #{model_bounds.center.x.to_m} #{model_bounds.center.y.to_m} 0 0 0 1 0 #{radius.to_m}")
					else
						f.puts("# Not terrain was desired... change this on the Preferences menu, if you want.")
					end


					f.puts("\n\n\n###### COMPONENT INSTANCES \n\n")
					comp_path = "./Components"
					defi=Sketchup.active_model.definitions
					anyluminaire = defi.select{|d| Labeler.luminaire? d }.length > 0
					light = File.open("#{comp_path}/Lights/all.lightsources",'w') if anyluminaire

					defi.each do |h|
						next if h.instances.count==0
						if h.is_a? Sketchup::ComponentDefinition then
							next if Labeler.solved_workplane?(h)
							next if Labeler.illuminance_sensor?(h)
							hName=Utilities.fix_name(h.name)
							instances=h.instances
							lightfile = "./Components/Lights/#{hName}.lightsource"
							instances.each do |inst|
								next if not inst.parent.is_a? Sketchup::Model
								next if Labeler.tdd?(inst)
								xform = self.get_component_string(inst)
								f.puts "#{xform} ./Components/#{hName}.rad"

								light.puts "#{xform} #{lightfile}" if File.file? lightfile

							end
						end
					end
					light.close if anyluminaire
				}
				return true
			end


			# Writes the standard Clear Sky
			# @author German Molina
			# @version 1.0
			# @return [Boolean] Success
			def self.write_sky

				OS.mkdir("./Skies")
				path="./Skies"

				info=Sketchup.active_model.shadow_info
				sun=info["SunDirection"]
				floor=Geom::Vector3d.new(sun.x, sun.y, 0)
				alt=sun.angle_between(floor).radians
				azi=floor.angle_between(Geom::Vector3d.new(0,-1,0)).radians
				azi=-azi if sun.x>0

				if alt >= 3.0 then
					File.open("#{path}/sky.rad",'w+'){ |f| #The file is opened
						f.puts("\n\n\n###### DEFAULT SKY \n\n")
						f.puts("!gensky -ang #{alt} #{azi} +s -g #{Config.albedo}\n\n")
						f.puts(self.sky_complement)
					}

					return true
				else
					File.open("#{path}/sky.rad",'w+'){ |f| #The file is opened
						f.puts "#night-time... No Sky"
					}
					return true
				end

			end

			# Writes the illuminance sensors
			# @author German Molina
			# @version 0.1
			# @return [Boolean] Success
			def self.write_photosensors

				sensors = Sketchup.active_model.definitions.select {|x| Labeler.illuminance_sensor?(x) }
				return true if sensors.length < 1 #do not do anything, but success
				sensors = sensors[0].instances
				return true if sensors.length < 1 #do not do anything, but success

				path="./Sensors"
				OS.mkdir(path)

				File.open("#{path}/sensors.pts",'w'){ |f| #The file is opened
					File.open("#{path}/sensor_dictionary.txt",'w'){|dic|
						sensors.each_with_index do |sensor,index|
							position = Photosensor.get_position(sensor)
							f.puts("#{position["px"]}   #{position["py"]}   #{position["pz"]}   #{position["nx"]}   #{position["ny"]}   #{position["nz"]}")
							if Labeler.has_gh_name(sensor) then	
								name = Utilities.fix_name(Labeler.get_name(sensor))						
								File.open("#{path}/#{name}.pt",'w'){|short_file|
									short_file.puts("#{position["px"]}   #{position["py"]}   #{position["pz"]}   #{position["nx"]}   #{position["ny"]}   #{position["nz"]}")
								}			
								dic.puts "#{index},#{name}"				
							end													
						end
					}					
				}
				return true
			end

			# Get the sky_complement, defining the sky and ground semi-hemispheres
			#
			# @author German Molina
			# @version 1.0
			# @return [String] the needed Sky and Ground semi-hemispheres
			def self.sky_complement
				return 	"skyfunc\tglow\tskyglow\n0\n0\n4\t0.99\t0.99\t1.1\t0\n\nskyglow\tsource\tskyball\n0\n0\n4\t0\t0\t1\t360\n\n"
			end



			# Export the ComponentDefinitions into separate files into "Components" folder.
			# Each file is autocontained, although some materials might be repeated in the "materials.mat" file.
			# @author German Molina
			# @version 0.6
			# @return [Boolean] Success
			def self.export_component_definitions
				defi=Sketchup.active_model.definitions.select{|x| x.instances.count!=0}

				return true if defi.length == 0 #dont do anything if there are no components
				wins = []
				any_workplane = false
				defi.each do |h|
					#skip the following
					next if h.image?
					next if Labeler.solved_workplane?(h)
					next if Labeler.illuminance_sensor?(h)
					next if not Utilities.has_relevant_content?(h.entities)


					folder = "Components"
					folder="TDDs" if Labeler.tdd?(h)
					comp_path="./#{folder}"

					hName=Utilities.fix_name(h.name)
					filename = "#{comp_path}/#{hName}.rad"

					entities=h.entities
					faces=Utilities.get_faces(entities)
					instances=Utilities.get_component_instances(entities)

					geom_string=""

					# write and next if it is a TDD
					if Labeler.tdd?(h) then
						TDD.write_tdd("./TDDs",h)
						next
					end

					if Labeler.luminaire?(h) then
						UI.messagebox "Error when exporting luminaire '#{h.name}'" if not Lamps.ies2rad(h, comp_path)
					end

					anyluminaire = instances.select{|inst| Labeler.luminaire? inst.definition }.length > 0
					OS.mkdir("./Components/Lights") if anyluminaire
					light = File.open("./Components/Lights/#{hName}.lightsource",'w') if anyluminaire

					instances.each do |inst| #include the nested components
						name = Utilities.fix_name(inst.definition.name)
						xform = self.get_component_string(inst)
						geom_string += "#{xform} ./#{name}.rad#{$/}"
						if Labeler.luminaire?(inst.definition) then
							light.puts "#{xform} ./#{Labeler.get_fixed_name(inst.definition)}.rad"
						end
					end
					light.close if anyluminaire
					geom_string+="#{$/}#{$/}"

					mat_array=[]
					faces.each do |fc| #then the rest of the faces
						next if fc.deleted? #skip deleted faces
						if Labeler.workplane? (fc) then
							any_workplane = true
						elsif Labeler.illum? (fc) then
							OS.mkdir("./Illums")
							tr = Utilities.get_all_global_transformations(fc,Geom::Transformation.new)
							tr.each_with_index{|t,index|
								File.open("#{path}/Illums/#{hName}_#{index}.rad",'w'){ |file|
									info = self.get_transformed_rad_string(fc,t,"#{Labeler.get_fixed_name(fc)}_#{index}")
									file.puts("void"+info[0])
								}
							}
						elsif Labeler.window? (fc) then
							wins << fc
						else #common surfaces
							info=self.get_rad_string(fc)
							next if not info # ignore if the ent does not exist anymore
							matName=Utilities.fix_name(info[1].name)+"_"+hName
							geom_string=geom_string+info[0].gsub("%MAT_NAME%",matName)
							mat_array=mat_array+[info[1]]
						end
					end

					if any_workplane then
						UI.messagebox("There is at least one workplane in component '#{hName}'. Please take it outside")
						return false
					end

					#Write materials and geometry
					mat_string = Utilities.mat_array_2_mat_string(mat_array,hName)
					OS.mkdir(comp_path)
					File.open(filename,'w+'){ |f|
						f.puts mat_string+geom_string
					}

				end	#end for each

				self.write_window_groups(wins)

				return true
			end #end method

			# Returns the String that has to be written in the scene file... !xform etc.
			# @author German Molina
			# @version 0.4
			# @param comp [Sketchup::ComponentInstance]
			# @return [string] xform comand
			def self.get_component_string(comp)

				t=comp.transformation.to_a

				x=t[12].to_m
				y=t[13].to_m
				z=t[14].to_m

				rx=Math::atan2(-t[9],t[10])
				c2=Math::sqrt(t[0]*t[0]+t[4]*t[4])
				ry=Math::atan2(t[8],c2)
				rz=Math::atan2(-t[4],t[0])


				ret="!xform -rz #{rz.radians} -ry #{ry.radians} -rx #{rx.radians} -t #{x} #{y} #{z}"

				return ret
			end

			# Export the RIF file, for creating renders
			# @author German Molina
			# @version 0.4
			# @return [Boolean] Success
			# @note It assumes that the relevant zone is interior.
			def self.write_rif_file(illums, windows)
				model=Sketchup.active_model
				box=model.bounds
				max=box.max
				min=box.min
				pages=model.pages

				File.open("./scene.rif",'w+'){ |f| #The file is opened
					f.puts("###############\n## RIF exported using Groundhog v"+Sketchup.extensions["Groundhog"].version.to_s+" in SketchUp "+Sketchup.version+"\n## Date of export: "+Time.now.to_s+"\n###############\n\n\n")

					f.puts("ZONE= I #{min.x.to_m} #{max.x.to_m} #{min.y.to_m} #{max.y.to_m} #{min.z.to_m}  #{max.z.to_m} \n")
					f.puts("UP=Z\n")
					f.puts("scene=./Skies/sky.rad ./scene.rad\n")
					f.puts("materials=./Materials/materials.mat\n")
					f.puts("QUAL=LOW\n")
					f.puts("DETAIL=LOW\n")
					f.puts("VAR=High\n")
					f.puts("RESOLUTION=560 560\n")
					f.puts("AMBFILE=ambient.amb\n")
					f.puts("INDIRECT=3\n")
					f.puts("PENUMBRAS=True\n")
					f.puts("REPORT=2")

					#then the pages
					f.puts("\n\n#VIEWS\n\n")
					pages.each do |page|
						f.puts("view="+page.name.tr(" ","_")+" -vf Views/"+page.name.tr(" ","_")+'.vf'+"\n")
					end

					#Then the illums
					f.puts("\n\n#ILLUMS\n\n")
					illums.each do |ill|
						name=Labeler.get_fixed_name(ill)
						f.puts("illum=./Illums/"+name+".rad\n")
					end



					#Then the window groups
					f.puts("\n\n#WINDOW GROUPS\n\n")
					groups=Utilities.get_win_groups(windows)
					groups.each do |gr|
						f.puts("illum=./Windows/"+gr.tr(" ","_")+".rad\n")
					end

					#then the rest of the windows
					f.puts("\n\n#OTHER WINDOWS\n\n")
					nwin=1 #this will count the windows
					windows.each do |win|
						c=Labeler.get_win_group(win)
						if c==nil then # if the window has no group

							winname=win.get_attribute("Groundhog","Name") #get the name
							if winname==nil then #if it does not have one
								f.puts("./Windows/WindowSet_"+nwin.to_s+".rad\n")
								nwin=nwin+1
							else #if it has one
								f.puts("./Windows/"+winname+".rad\n")
							end
						end
					end


				}
				return true
			end




		end #end module

	end #end Groundhog
end
