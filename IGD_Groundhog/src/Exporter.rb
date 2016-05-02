module IGD
	module Groundhog

		# This class has the methods that allow exporting the SketchUp model.
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
						mat=Sketchup.active_model.materials["GH_default_glass"] #If it is a glass
						if mat==nil #this means the materials has been deleted or are not there yet.
							Materials.add_default_glass
							mat=Sketchup.active_model.materials["GH_default_glass"] #If it is a glass
						end
					else
						mat=Sketchup.active_model.materials["GH_default_material"] #if it is anything else (Illums and Workplanes will be ignored later)
						if mat==nil #material deleted
							Materials.add_default_material
							mat=Sketchup.active_model.materials["GH_default_material"] #if it is anything else (Illums and Workplanes will be ignored later)
						end
					end
				end
				return mat
			end


			# Assess the String that should be written in the Radiance geometry file.
			#
			# If no material is assigned, or the material is not supported, it assigns one of the
			# default materials.
			# @author German Molina
			# @version 1.3
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @param trans [Array <Sketchup::Transformation>] list of transformations to apply to the face.
			# @return [<Array>] The string to be written in the .rad file, and the material
			def self.get_rad_string(face,trans)
				self.close_face([], 1, 4, face)
				mat = self.get_material(face)
				vert=face.vertices #get the vertices
				string1="\tpolygon\t"+Labeler.get_name(face).tr(" ","_").tr("#","_")+"\n0\n0\n"+(3*vert.length).to_s #Write the standard first three lines
				string2=""
				vert.each { |v|
					p=v.position
					trans.each { |tr| p.transform!(tr) }
					string2=string2+"\t#{p.x.to_m.to_f}\t#{p.y.to_m.to_f}\t#{p.z.to_m.to_f}\n"
				}
				string2+="\n\n"

				Utilities.delete_label(face.edges,"added") #Maybe this could be done later... and it would be faster...?
				return [string1+string2,mat] #Returns the string and the material
			end

			# Same as get_rad_string, but reversing the order of the vertices.
			# @author German Molina
			# @version 1.3
			# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
			# @param trans [Array <Sketchup::Transformation>] list of transformations to apply to the face.
			# @return [<Array>] The string to be written in the .rad file, and the material
			def self.get_reversed_rad_string(face,trans)
				self.close_face([], 1, 4, face)
				mat = self.get_material(face)
				vert=face.vertices.reverse #get the vertices
				string1="\tpolygon\t"+Labeler.get_name(face).tr(" ","_").tr("#","_")+"\n0\n0\n"+(3*vert.length).to_s #Write the standard first three lines
				string2=""
				vert.each { |v|
					p=v.position
					trans.each { |tr| p.transform!(tr) }
					string2=string2+"\t#{p.x.to_m.to_f}\t#{p.y.to_m.to_f}\t#{p.z.to_m.to_f}\n"
				}
				string2+="\n\n"

				Utilities.delete_label(face.edges,"added") #Maybe this could be done later... and it would be faster...?
				return [string1+string2,mat] #Returns the string and the material
			end



			# Recursively connects the interior and the exterior loops of a face.
			#
			# This allow efficient exporting by exporting only One Radiance polygon for each SketchUp face.
			#
			# This method exists because SketchUp allows interior loops, but Radiance does not.
			#
			# This method is called within #get_rad_string
			# @author German Molina
			# @version 1.0.5
			# @param lines [Array] Should be empty
			# @param p [Int] Should be different from w. It really does not matter what the input is (see source code)
			# @param w [Int] Should be different from p. It really does not matter what the input is (see source code)
			# @param face [face] SketchUp face to close.
			# @return [Void]
			# @example Close a selected face
			#   close_face([],1,4,Sketchup.active_model.selection[0])
			def self.close_face(lines, p, w, face)

				entities = face.parent.entities

				if p!=0 and p!=w then
				#p, here, was added because this function sometimes entered to an infinite loop... so when
				#nothing changes between one close_face implementation and the next one, we stop it.
					w=0 #this will count the number of interior loops

						loops=face.loops #get the loops
						if loops.length > 1 then #it means it has interior loops
							#we add this loop to the new selection, so it will be checked on the next iteration.

							out_vert=face.outer_loop.vertices #and identify the outer loop
							min_dist=1000000 #just to declare the variable with a big number
							pt_o=Geom::Point3d.new(0,0,0) #Declare the outer and inner points.
							pt_e=Geom::Point3d.new(0,0,0)
							loops.each do |j| #Then, for all the loops
								if ! j.outer? #that are inner loops
									w=w+1 #we take note of it
									in_vert=j.vertices #We extract the vertices of the interior loop
									in_vert.each do |k| #and for each of them
										out_vert.each do |l| #We check the distance to the vertices of the exterior loop
											dist=l.position.distance(k.position)
											if dist<min_dist #if the distance is smaller than the smallest until now
												min_dist=dist #we change it
												pt_o=k.position #and store the points
												pt_e=l.position
											end
										end
									end
								end
							end
							ln=entities.add_line(pt_o,pt_e) #And connect it to the outer loop
							lines=lines+[ln] #store the lines, since they will be deleted after the export.
						end

					self.close_face(lines,w,p,face)
				end

				lines.each do |i|
					if i==nil then

					else
						i.set_attribute("Groundhog","Label","added")
					end
				end
			end


			# Export the entire model to the path where the model is saved.
			#
			# Each layer is exported on a different file with the name of the layer, and the
			# "illums" of each layer are also exported on a separate file. To make a different organization,
			# #exportFaces method should be modified.
			# @author German Molina
			# @version 1.0
			# @param path [String] The path where the model will be exported
			# @param lights_on [Boolean] The lights will be exported as ON if true, and OFF if false
			# @return [Boolean] Success
			# @note this method used to be called 'do_multiphase'
			def self.export(path,lights_on)
				OS.clear_path(path)
				begin
					model=Sketchup.active_model
					op_name = "Export"
					model.start_operation( op_name,true )

					#Export the faces and obtain the modifiers
					mod_list=self.export_layers(path)
					return false if not mod_list #return right away
					return false if not self.export_modifiers(path,mod_list)
					return false if not self.write_sky(path)
					return false if not self.export_views(path)
					return false if not self.write_scene_file(path)
					return false if not self.export_component_definitions(path, lights_on)
					return false if not self.write_illuminance_sensors(path)

					Sketchup.active_model.materials.remove(Sketchup.active_model.materials["GH_default_material"])

					model.commit_operation
				rescue Exception => ex
<<<<<<< Updated upstream
					UI.messagebox ex
=======
					UI.messagebox ex		
>>>>>>> Stashed changes
				end
				return true
			end



			# This method exports the faces organized in Groundhog distribution
			#
			# Each layer will be exported on on a different file, as well as each illum of each layer.
			#
			# @author German Molina
			# @version 1.0.5
			# @param path [String] Directory where the Geometry folder is.
			# @return [Array<Material>] Array of all the unique materials assigned to the exported faces.
			# @return false if not succss or cancelled
			# @example Export the whole model.
			#   mat_list=Exporter.exportFaces(path, SketchUp.active_model.entities)
			def self.export_layers(path)

				OS.mkdir("#{path}/Geometry")

				mat_list=[] #This will store the modifiers (materials) of each face.
				model=Sketchup.active_model
				entities=model.entities

				faces=Utilities.get_faces(entities)

				windows=[] # this array will store the windows in case their are needed
				workplanes=[]
				illums=[]

				#We get the layers in the model
				layers=model.layers
				#we open one file per each layer
				writers=[] #this is an array of writers
				layers.each do |lay|
					writers=writers+[File.open("#{path}/Geometry/#{Utilities.fix_name(lay.name)}.rad",'w+')]
				end


				#now we loop over the faces, and write them were they belong
				faces.each do |fc| #for each face
					info=self.get_rad_string(fc,[]) #get the information

					if Labeler.window?(fc)
						#Window groups will be exported separatedly
						windows=windows+[fc]
					elsif Labeler.workplane?(fc) then
						#if it is workplane, store
						workplanes=workplanes+[fc]
					elsif Labeler.illum?(fc) then
						illums=illums+[fc]
					else
						i=0
						layers.each do |ly| #we look for the correct layer
							if fc.layer.==ly then
								#write the information
								writers[i].write(Utilities.fix_name(info[1].name)+info[0])
								#store the material
								mat_list=mat_list+[info[1]]
								#and purge the list
								mat_list.uniq!
							end #end of if in find layer
							i=i+1
						end #end in for each layer

					end #end of check the label of the face
				end #end for each faces

				#Close the rest of the files
				writers.each do |w|
					w.close
				end

				#write the workplanes
				return false if not self.write_workplanes(path,workplanes)

				#Write windows
				return false if not self.write_window_groups(path,windows)

				#Write illums
				return false if not self.write_illums(path,illums,[],false)

				#write rif
				return false if not self.write_rif_file(path, illums, windows)

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
			# @param path [String] Directory to export the View.
			# @return [Boolean] Success
			# @example Export the actual view
			#   Exporter.exportView(path)
			def self.export_views(path)

				OS.mkdir("#{path}/Views")
				path="#{path}/Views"
				#Export the actual view
				File.open("#{path}/view.vf",'w+'){|f|
					f.write(self.get_view_string(Sketchup.active_model.active_view.camera))
				}
				#then the scenes
				pages=Sketchup.active_model.pages
				if pages.count>=1 then
					pages.each do |page|
						File.open("#{path}/#{Utilities.fix_name(page.name)}.vf",'w+'){|f|
							f.write(self.get_view_string(page.camera))
						}
					end
				end
				return true

			end

			# Export the window groups. This method is called from #exportFaces. Creates a Window folder within the directory.
			# @author German Molina
			# @version 1.1
			# @param path [String] Directory to export the Window Groups.
			# @param windows [faces] An array with windows, selected during #exportFaces.
			# @return [Boolean] Success
			def self.write_window_groups(path,windows)

				return true if windows.length < 1 #it did success... but there were not any windows

				OS.mkdir("#{path}/Windows")
				groups=Utilities.get_win_groups(windows)
				ngroups=groups.length
				rad_strings=Array.new(ngroups,"") #store the geometry of the windows
				materials=Array.new(ngroups,[]) #store the materials of the windows
				nwin=1 #this will count the windows

				windows.each do |win|
					c=Labeler.get_win_group(win)
					info=self.get_rad_string(win,[])
					if c!=nil then # if the window has a group
						# We write using the writer of that group
						i=0
						while i<ngroups
							if c==groups[i] then #if the group of the window is the same as the one in the array
								materials[i]+=[info[1]]
								rad_strings[i]+='#normal (points inside): '+win.normal.x.to_s+' '+win.normal.y.to_s+' '+win.normal.z.to_s+"\n"
								rad_strings[i]+=info[1].name.tr(" ","_")+' '+info[0]+"\n\n" #Window with its material
								break # we leave the loop
							end
							i+=1
						end

					else #if not
						#we write using a new writer
						winname=Labeler.get_name(win)
						if winname==nil then
							wr=File.open("#{path}/Windows/WindowSet_#{nwin}.rad",'w+')
							nwin+=1
						else
							wr=File.open("#{path}/Windows/#{winname.tr(" ","_")}.rad",'w+')
						end
						wr.write(self.get_mat_string(info[1],false)+"\n\n"+info[1].name+' '+info[0]) #Window with its material
						wr.close
					end
				end

				#Close the rest of the files
				writers=[]
				count=0
				groups.each do |gr|
					materials[count].uniq!
					mat_string=""
					materials[count].each do |mat|
						mat_string+=self.get_mat_string(mat,false)
					end
					mat_string+="\n\n"

					w=File.open("#{path}/Windows/#{gr.tr(" ","_")}.rad",'w+')
					w.write(mat_string+rad_strings[count])
					w.close
					count=count+1
				end

				return true

			end

			# Writes the sensors that are over the workplanes. Creates a Workplanes folder on the directory.
			#
			# The prompt will ask for the spacing, and a .pts file will be written on the path on the Workplanes folder.
			#
			# The name of the file will be the name of the entity.
			# @author German Molina
			# @version 1.2
			# @param path [String] Directory to export the Window Groups.
			# @param entities [entities] Array of workplanes.
			# @return [Boolean] Success
			def self.write_workplanes(path,entities)

				return true if entities.length<1 #we export this only if there is any workplane... success
<<<<<<< Updated upstream
				d=Config.desired_pixel_area
=======
<<<<<<< HEAD
				d=Config.pixel_area
=======
				d=Config.desired_pixel_area
>>>>>>> Model-analysis
>>>>>>> Stashed changes
				return false if not d
				d=d.m

				OS.mkdir("#{path}/Workplanes")
				path="#{path}/Workplanes"

				entities.each do |ent| #for all the entities (which are faces)
					if Labeler.workplane?(ent) then #Only workplanes
						name=Labeler.get_name(ent) #Get the name of the surface
						mesh = ent.mesh
						points = mesh.points
						polygons = mesh.polygons
						triangles = Triangle.triangulate(points,polygons)
						File.open("#{path}/#{name}.pxl",'w+'){ |pixels|
							File.open("#{path}/#{name}.pts",'w+'){ |points|
								#now the triangles
								triangles.each do |triangle|
									pos = Triangle.get_center(triangle)
									n = Triangle.get_normal(triangle)
									pixels.puts "#{triangle[0].x.to_m},#{triangle[0].y.to_m},#{triangle[0].z.to_m},#{triangle[1].x.to_m},#{triangle[1].y.to_m},#{triangle[1].z.to_m},#{triangle[2].x.to_m},#{triangle[2].y.to_m},#{triangle[2].z.to_m}"
									#points.puts "#{pos.x.to_m}\t#{pos.y.to_m}\t#{pos.z.to_m}\t#{n.x}\t#{n.y}\t#{n.z}"
									points.puts "#{pos.x.to_m}\t#{pos.y.to_m}\t#{pos.z.to_m}\t0\t0\t1"
								end
							}
						}
					end
				end

				return true

			end


			# Exports illum surfaces
			# @author German Molina
			# @version 1.0
			# @param path [String] Directory to export the Window Groups.
			# @param entities [Array <Sketchup::Face>] An array with illums, selected during exportFaces.
			# @param trans [Array <Sketchup::Transformation>] An array with transformations to apply to the face.
			# @param ext [String] An extension that will be assigned to the file.
			# @return [Boolean] Success
			def self.write_illums(path,entities,trans,ext)

				return true if entities.length<1  #success... did not export, though.

				OS.mkdir("#{path}/Illums")
				path="#{path}/Illums"

				entities.each do |ent| #for all the entities (which are faces)
					if Labeler.illum?(ent) then #Only illums
						name=Labeler.get_name(ent) #Get the name of the surface
						name="#{Utilities.fix_name(ent.parent.name)}_#{name}" if ent.parent.is_a? Sketchup::ComponentDefinition
						name+="_#{ext}" if ext
						info=self.get_rad_string(ent,trans)

						File.open("#{path}/#{Utilities.fix_name(name)}.rad",'w+'){ |f| #The file is opened
							f.write("void "+info[0])
						}

					end
				end

				return true
			end


			# Export the Radiance Modifiers
			# @author German Molina
			# @version 1.0
			# @param path [String] Directory to export the Window Groups.
			# @param mat_array [faces] An array with the materials to export
			# @return [Boolean] Success
			def self.export_modifiers(path,mat_array)

				OS.mkdir("#{path}/Materials")
				path="#{path}/Materials"
				File.open("#{path}/materials.mat",'w+'){ |f| #The file is opened
					mat_array.each do |mat|
						f.write(self.get_mat_string(mat,false)+"\n\n")
					end
				}
				return true
			end


			# Export the Scene file. The Scene file references the different Radiance files to create the model.
			# @author German Molina
			# @version 0.8
			# @param path [String] Directory to export the scene file
			# @return [Boolean] success
			def self.write_scene_file(path)
				File.open("#{path}/scene.rad",'w+'){ |f| #The file is opened
					f.write("###############\n## Scene exported using Groundhog v"+Sketchup.extensions["Groundhog"].version.to_s+" from SketchUp "+Sketchup.version+"\n## Date of export: "+Time.now.to_s+"\n###############\n")

					f.write("\n\n\n###### GEOMETRY \n\n")

					Sketchup.active_model.layers.each do |layer|
						name=layer.name.tr(" ","_")
						f.write("!xform ./Geometry/"+name+".rad\n")
					end

					f.write("\n\n\n###### GROUND \n\n")
					albedo = Config.albedo
					model_bounds=Sketchup.active_model.bounds
					radius = IGD::Groundhog::Config.terrain_oversize * model_bounds.diagonal
					f.write("void plastic terrain_mat\n0\n0\n5\t#{albedo}\t#{albedo}\t#{albedo}\t0\t0")
					f.write("\n\nterrain_mat ring ground 0 0 8 #{model_bounds.center.x.to_m} #{model_bounds.center.y.to_m} 0 0 0 1 0 #{radius.to_m}")

					f.write("\n\n\n###### COMPONENT INSTANCES \n\n")
					defi=Sketchup.active_model.definitions
					defi.each do |h|
						next if h.instances.count==0
						if h.is_a? Sketchup::ComponentDefinition then
							next if Labeler.solved_workplane?(h)
							hName=Utilities.fix_name(h.name)
							instances=h.instances
							comp_path = " ./Components/"
							comp_path = " ./TDDs/" if Labeler.tdd?(h)
							instances.each do |inst|
								next if not inst.parent.is_a? Sketchup::Model
								f.write(self.get_component_string(comp_path,inst,hName))
							end
						end
					end


				}
				return true
			end


			# Writes the standard Clear Sky
			# @author German Molina
			# @version 1.0
			# @param path [String] Directory to export the sky file
			# @return [Boolean] Success
			def self.write_sky(path)

				OS.mkdir("#{path}/Skies")
				path="#{path}/Skies"

				info=Sketchup.active_model.shadow_info
				sun=info["SunDirection"]
				floor=Geom::Vector3d.new(sun.x, sun.y, 0)
				alt=sun.angle_between(floor).radians
				azi=floor.angle_between(Geom::Vector3d.new(0,-1,0)).radians
				azi=-azi if sun.x>0

				if alt >= 3.0 then
					File.open("#{path}/sky.rad",'w+'){ |f| #The file is opened
						f.write("\n\n\n###### DEFAULT SKY \n\n")
							f.write("!gensky -ang #{alt} #{azi} +s -g #{Config.albedo}\n\n")
							f.write(self.sky_complement)
					}

					return true
				else
					File.open("#{path}/sky.rad",'w+'){ |f| #The file is opened
						f.write "#night-time... No Sky"
					}
					return true
				end

			end

			# Writes the illuminance sensors
			# @author German Molina
			# @version 0.1
			# @param path [String] Directory to export the sky file
			# @return [Boolean] Success
			def self.write_illuminance_sensors(path)

				sensors = Sketchup.active_model.definitions.select {|x| Labeler.illuminance_sensor?(x) }
				return true if sensors.length < 1 #do not do anything, but success
				sensors = sensors[0].instances
				return true if sensors.length < 1 #do not do anything, but success

				path="#{path}/Illuminance_Sensors"
				OS.mkdir(path)

				File.open("#{path}/sensors.pts",'w+'){ |f| #The file is opened
					sensors.each do |sensor|
						vdir = sensor.transformation.zaxis
						vx = vdir[0]
						vy = vdir[1]
						vz = vdir[2]
						pos = sensor.transformation.origin
						px = pos[0].to_m
						py = pos[1].to_m
						pz = pos[2].to_m
						f.write("#{px}   #{py}   #{pz}   #{vx}   #{vy}   #{vz}\n")
					end
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

			# Get the white sky, for calculating DC matrix, for example
			#
			# @author German Molina
			# @version 1.0
			# @param bins [Integer] The number of reinhart subdivitions of the sky
			# @return  [String] white sky definition
			def self.white_sky(bins)
				return 	"\#@rfluxmtx h=u u=Y\nvoid glow ground_glow\n0\n0\n4 1 1 1 0\n\nground_glow source ground\n0\n0\n4 0 0 -1 180\n\n\#@rfluxmtx h=r#{bins} u=Y\nvoid glow sky_glow\n0\n0\n4 1 1 1 0\n\nsky_glow source sky\n0\n0\n4 0 0 1 180"
			end

			# Export the ComponentDefinitions into separate files into "Components" folder.
			# Each file is autocontained, although some materials might be repeated in the "materials.mat" file.
			# @author German Molina
			# @version 0.6
			# @param path [String] Directory to export the model (scene file)
			# @param lights_on [Boolean] Lights will be exported as ON if true and OFF if false.
			# @return [Boolean] Success
			def self.export_component_definitions(path,lights_on)
				defi=Sketchup.active_model.definitions.select{|x| x.instances.count!=0}
				comp_path="#{path}/Components"

				return true if defi.length == 0 #dont do anything if there are no components

				defi.each do |h|
					#skip the following
					next if h.image?
					next if Labeler.solved_workplane?(h)
					next if Labeler.illuminance_sensor?(h)

					comp_path="#{path}/TDDs" if Labeler.tdd?(h)

					hName=Utilities.fix_name(h.name)
					filename = "#{comp_path}/#{hName}.rad"

					entities=h.entities
					faces=Utilities.get_faces(entities)
					instances=Utilities.get_component_instances(entities)

					geom_string=""

					# Add the illum if it is a luminaire
					if Labeler.local_luminaire?(h) then #add the illum
						mult = 1.0
						mult = 0 if not lights_on
						geom_string += Lamps.ies2rad(Labeler.get_value(h),mult,h, comp_path)
					end

					# write and next if it is a TDD
					if Labeler.tdd?(h) then
						tdd_path = "#{path}/TDDs"
						OS.mkdir(tdd_path)
						tdd_geom = TDD.write_tdd(tdd_path,h)
						if tdd_geom then
							File.open(filename,'w+'){ |f|
								f.write tdd_geom
							}
						end
						next
					end


					instances.each do |inst| #include the nested components
						geom_string=geom_string+self.get_component_string(" ./",inst,Utilities.fix_name(inst.definition.name))
					end
					geom_string+="\n\n"

					mat_array=[]
					#wp_array=[]
					#ill_array=[]
					#window_array=[]
					faces.each do |fc| #then the rest of the faces
						if Labeler.workplane? (fc) then
						#	wp_array << fc
						elsif Labeler.illum? (fc) then
						#	ill_array << fc
						elsif Labeler.window? (fc) then
						#	window_array << fc
						else #common surfaces
							info=self.get_rad_string(fc,[])
							matName=Utilities.fix_name(info[1].name)+"_"+hName
							geom_string=geom_string+matName+info[0]
							mat_array=mat_array+[info[1]]
						end
					end

					#h.instances.each do |inst|
						#write illums
					#	self.write_illums(path,ill_array,[],Labeler.get_name(inst))

						#write windows
						#return false if not self.write_illums(path,ill_array)

						#write workplanes
						#return false if not self.write_illums(path,ill_array)
					#end


					#Write materials and geometry
					mat_string = Utilities.mat_array_2_mat_string(mat_array,hName)
					OS.mkdir(comp_path)
					File.open(filename,'w+'){ |f|
						f.write mat_string+geom_string
					}



				end	#end for each

				return true
			end #end method

			# Returns the String that has to be written in the scene file... !xform etc.
			# @author German Molina
			# @version 0.4
			# @param comp [Sketchup::ComponentInstance]
			# @return [string] xform comand
			def self.get_component_string(path,comp,name)

				t=comp.transformation.to_a

				x=t[12].to_m
				y=t[13].to_m
				z=t[14].to_m

				rx=Math::atan2(-t[9],t[10])
				s1=Math::sin(rx)
				c1=Math::cos(rx)
				c2=Math::sqrt(t[0]*t[0]+t[4]*t[4])
				ry=Math::atan2(t[8],c2)
				rz=Math::atan2(-t[4],t[0])


				ret="!xform -rz "+rz.radians.to_s+" -ry "+ry.radians.to_s+" -rx "+rx.radians.to_s+" -t "+x.to_s+" "+y.to_s+" "+z.to_s+path+name+".rad\n"

				return ret
			end

			# Export the RIF file, for creating renders
			# @author German Molina
			# @version 0.4
			# @param path [String] Directory to export the RIF file
			# @return [Boolean] Success
			# @note It assumes that the relevant zone is interior.
			def self.write_rif_file(path, illums, windows)
				model=Sketchup.active_model
				box=model.bounds
				max=box.max
				min=box.min
				pages=model.pages

				File.open("#{path}/scene.rif",'w+'){ |f| #The file is opened
					f.write("###############\n## RIF exported using Groundhog v"+Sketchup.extensions["Groundhog"].version.to_s+" in SketchUp "+Sketchup.version+"\n## Date of export: "+Time.now.to_s+"\n###############\n\n\n")

					f.write("ZONE= I #{min.x.to_m} #{max.x.to_m} #{min.y.to_m} #{max.y.to_m} #{min.z.to_m}  #{max.z.to_m} \n")
					f.write("UP=Z\n")
					f.write("scene=./Skies/sky.rad ./scene.rad\n")
					f.write("materials=./Materials/materials.mat\n")
					f.write("QUAL=LOW\n")
					f.write("DETAIL=LOW\n")
					f.write("VAR=High\n")
					f.write("RESOLUTION=560 560\n")
					f.write("AMBFILE=ambient.amb\n")
					f.write("INDIRECT=3\n")
					f.write("PENUMBRAS=True\n")
					f.write("REPORT=2")

					#then the pages
					f.write("\n\n#VIEWS\n\n")
					pages.each do |page|
						f.write("view="+page.name.tr(" ","_")+" -vf Views/"+page.name.tr(" ","_")+'.vf'+"\n")
					end

					#Then the illums
					f.write("\n\n#ILLUMS\n\n")
					illums.each do |ill|
						name=Labeler.get_name(ill).tr(" ","_") #Get the name of the surface
						f.write("illum=./Illums/"+name+".rad\n")
					end



					#Then the window groups
					f.write("\n\n#WINDOW GROUPS\n\n")
					groups=Utilities.get_win_groups(windows)
					groups.each do |gr|
						f.write("illum=./Windows/"+gr.tr(" ","_")+".rad\n")
					end

					#then the rest of the windows
					f.write("\n\n#OTHER WINDOWS\n\n")
					nwin=1 #this will count the windows
					windows.each do |win|
						c=Labeler.get_win_group(win)
						if c==nil then # if the window has no group

							winname=win.get_attribute("Groundhog","Name") #get the name
							if winname==nil then #if it does not have one
								f.write("./Windows/WindowSet_"+nwin.to_s+".rad\n")
								nwin=nwin+1
							else #if it has one
								f.write("./Windows/"+winname+".rad\n")
							end
						end
					end


				}
				return true
			end

			# Returns the Radiance primitive of a SketchUp material.
			#  It first checks if it is available in the library, and if not, it guesses it.
			#  If inputted a name (instead of "False"), the primitive's name will be forced to be
			#  the inputted value. This is useful for exporting components.
			# @author German Molina
			# @version 0.4
			# @param material [Sketchup::Material] SketchUp material
			# @param name [String] The desired name for the final Radiance material
			# @return [String] Radiance primivite definition for the material
			def self.get_mat_string(material,name)
				matName=material.name.tr(" ","_").tr("#","_")
				matName=name if name #if inputted a name, overwrite.

				if Labeler.local_material?(material) then
					value= Labeler.get_value(material)
					return value[0]+"\t"+matName+"\n"+value[1]
				else #not local, then guess the material
					mat_string=""

					if material.texture==nil then
						color=material.color
					else
						color=material.texture.average_color
					end
					r=color.red/255.0
					g=color.green/255.0
					b=color.blue/255.0

					mat_string=mat_string+"## guessed Material\n\n"
					if material.alpha < 1 then #then this is a glass
						r=r*material.alpha #This is probably wrong... but it does the job.
						g=g*material.alpha
						b=b*material.alpha
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s
						mat_string=mat_string+"void\tglass\t"+matName+"\n0\n0\n3\t"+rgb+"\n"
					else #This is an opaque material
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s+"\t0\t0"
						mat_string=mat_string+"void\tplastic\t"+matName+"\n0\n0\n5\t"+rgb+"\n"
					end
					return mat_string
				end

			end


		end #end class

	end #end module
end
