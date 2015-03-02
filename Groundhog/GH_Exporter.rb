# This class has the methods that allow exporting the SketchUp model.
class GH_Exporter
	
	
	
	# This method is was designed to get the orientation of a window. 
	#
	# The idea is to avoid calculating of some Daylight Matrix.
	# @author German Molina	
	# @version 1.0
	# @param face [face] SketchUp face, that should be a window.
	# @return [int] Orientation. North is 0, and degrees augment counterclockwise. East is 90, West is 270. 
	#   Maybe we could put the 0 to North??
	# @todo Verify and debug when implementing this feature.
	# @example Get the orientation of a face
	#   face=Sketchup.active_model.selection[0]
	#   orientation=GH_Exporter.get_orientation(face)
	# @note This method is unused because this feature is not supported yet.
	# @deprecated until someone needs it.
	def self.get_orientation(entity)
		#it has to be reversed, because the normal of the windows look inside.
		normal=entity.normal
		ang=normal.angle_between(Geom::Vector3d.new(0,-1,0)).rad
	
		if normal.z.abs > 0.001 then 
		#This just work for vertical surfaces.
			return -1
		else
			if normal.x > 0 then 
				return (ang+1.5)-(ang+1.5)%3
			else
				ang=360-ang
				return (ang+1.5)-(ang+1.5)%3
			end	
		end
	
	end

	# Writes an array into a file. 
	# @author German Molina	
	# @version 1.0
	# @param list [Array<String>] The list to be written
	# @param path [String] The path of the file.
	# @return [Void]
	# @deprecated useless for now.
	def self.writeArray(list,path)
		File.open(path, 'w') {|f| 
			list.each do |i|
				f.write(i+"\n\n")
			end	
		}
	end

	# Gets the path where the SketchUp model is saved. If it is not saved, it will return false.
	# @author German Molina	
	# @version 1.0
	# @param [Void]
	# @return [String] Path where the model is saved.
	# @example Get the path
	#   path=GH_Exporter.getpath
	def self.getpath	 
		model=Sketchup.active_model
		path=model.path
		return false if path=="" #model has not been saved
				
		p=path.split(GH_OS.slash) 
		path=""
		#I do not remember why I did this split... probably because of Window-Mac stuff.
		# it is not slow anyway... not hurting anyone.
		for i in 0..p.length-2
			path=path+p[i]+GH_OS.slash  
		end
		
		return path
	end

	# Assess the String that should be written in the Radiance geometry file.
	#
	# If no material is assigned, or the material is not supported, it assigns one of the 
	# default materials.
	# @author German Molina	
	# @version 1.3
	# @param face [Sketchup::Face] SketchUp face to be exported (in case the group is inside a group)
	# @param tr [Boolean] Option for transforming the polygon with the parent(s). 
	# @return [<Array>] The string to be written in the .rad file, and the material
	# @note tr=True is used for exporting layers, and tr=False is for exporting Components, that are located
	#   in the Scene.rad file using Radiance's !xform program. 
	def self.get_rad_string(face,tr)
		
		self.close_face([], 1, 4, face)

		trans=[]
		if tr then #If we want to transform everything.
			par=face.parent
			until par.is_a? Sketchup::Model 
				par=par.instances[0]
				trans=trans+[par.transformation]
				par=par.parent
			end
		end

		mat=face.material
		if mat==nil then # If the face does not have a front material
			mat=face.back_material # the back material will be tested
		end
		if mat==nil then # If it does not have a Back material either
			if GH_Labeler.window?(face) then #defaults are assigned
				mat=Sketchup.active_model.materials["GH_default_glass"] #If it is a glass
				if mat==nil #this means the materials has been deleted
					Sketchup.active_model.materials.add "GH_default_glass"
					Sketchup.active_model.materials["GH_default_glass"].color=[0.0,0.0,1.0]
					Sketchup.active_model.materials["GH_default_glass"].alpha=0.2
					mat=Sketchup.active_model.materials["GH_default_glass"] #If it is a glass
				end
			else
				mat=Sketchup.active_model.materials["GH_default_material"] #if it is anything else (Illums and Workplanes will be ignored later)
				if mat==nil #material deleted
					Sketchup.active_model.materials.add "GH_default_material"
					Sketchup.active_model.materials["GH_default_material"].color=[0.7,0.7,0.7]
					mat=Sketchup.active_model.materials["GH_default_material"] #if it is anything else (Illums and Workplanes will be ignored later)
				end
			end
		end

#		puts GH_Labeler.get_name(face) if not GH_Utilities.planar?(face)
		
		vert=face.vertices #get the vertices 
		
		n=3*vert.length
		string1="\tpolygon\t"+GH_Labeler.get_name(face)+"\n0\n0\n"+n.to_s #Write the standard first three lines
	
		string2=""
		vert.each do |v|
			p=v.position
			trans.each do |tr|
				p.transform!(tr)
			end
			
			string2=string2+"\t#{p.x.to_m.to_f}\t#{p.y.to_m.to_f}\t#{p.z.to_m.to_f}\n"
		end
		string3="\n\n"
		
		GH_Utilities.delete_label(face.edges,"added") #Maybe this could be done later... and it would be faster...?
		
		return [string1+string2+string3,mat] #Returns the string and the material
		
	end

	

	# Recursively connects the interior and the exterior loops of a face.
	#
	# This allow efficient exporting by exporting only One Radiance polygon for each SketchUp face.
	#
	# This method exists because SketchUp allows interior loops, but Radiance does not.
	#
	# This method is called within {#get_rad_string}
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
	# {#exportFaces} method should be modified.
	# @author German Molina	
	# @version 1.0
	# @param [Void]
	# @return [Void]
	# @note this method used to be called 'do_multiphase'
	def self.export
		
		path=self.getpath #it returns false if not successful
		if not path	then
			path=""
		end
		
		path_to_save = UI.savepanel("Export model for radiance simulations", path, "Radiance Model")
		path_to_save=path_to_save.tr(" ","_").tr("#","_")
				
		s=GH_OS.slash
		system("mkdir "+path_to_save)
		path=path_to_save+s
		
		#Export the faces and obtain the modifiers
		mod_list=self.export_layers(path, Sketchup.active_model.entities)
		self.export_modifiers(path,mod_list)
		self.export_views(path)
		self.write_scene_file(path)
		self.export_component_definitions(path)
		return true
	end

	
	
	# This method exports the faces organized in Groundhog distribution
	#
	# Each layer will be exported on on a different file, as well as each illum of each layer.
	#
	# @author German Molina	
	# @version 1.0.5
	# @param path [String] Directory where the Geometry folder is.
	# @param entities [Array<faces>] Array with the entities to export.
	# @return [Array<Material>] Array of all the unique materials assigned to the exported faces.
	# @example Export the whole model.
	#   mat_list=GH_Exporter.exportFaces(path, SketchUp.active_model.entities)
	def self.export_layers(path, entities)
	
		system("mkdir "+path+"Geometry")

		faces=GH_Utilities.get_all_layer_faces(entities,[]) #in order to include groups.
		
		mat_list=[] #This will become the name of the modifiers (materials) of each face.
		model=Sketchup.active_model	
		entities=model.entities
		s=GH_OS.slash #just to avoid calling the method on every iteration.
		windows=[] # this array will store the windows in case their are needed
		workplanes=[]
	
		#We get the layers in the model
		layers=model.layers
		#we open one file per each layer
		writers=[] #this is an array of writers
		ill_writers=[] #this is an array of illum writers
		layers.each do |lay|
			writers=writers+[File.open(path+'Geometry'+s+lay.name.tr(" ","_")+'.rad','w')]
			ill_writers=ill_writers+[File.open(path+'Geometry'+s+'illums-'+lay.name.tr(" ","_")+'.rad','w')] 
		end
		
		
		#now we loop over the faces, and write them were they belong	
		faces.each do |fc| #for each face
			info=self.get_rad_string(fc,true) #get the information
	
			if GH_Labeler.window?(fc) 
				#Window groups will be exported separatedly
				windows=windows+[fc]
			elsif GH_Labeler.workplane?(fc) then 
				#if it is workplane, store
				workplanes=workplanes+[fc]
			else 
				i=0
				layers.each do |ly| #we look for the correct layer
					if fc.layer.==ly then
						if GH_Labeler.illum?(fc) then 
							ill_writers[i].write("void"+info[0])
						else #if it is anything else
							#write the information
							writers[i].write(info[1].name.tr(" ","_")+info[0])
							#store the material
							mat_list=mat_list+[info[1]]
							#and purge the list
							mat_list.uniq!
						end							
					end #end of if in find layer
					i=i+1		
				end #end in for each layer
				
			end #end of check the label of the face
		end #end for each faces
	
		#Close the rest of the files
		writers.each do |w|
			w.close
		end
		ill_writers.each do |w|
			w.close
		end
		#write the workplanes
		self.write_sensors(path,workplanes)

		#Write windows
		self.write_window_groups(path,windows)

	
		return mat_list
	end

	# Get the String that describes a view from a certain SketchUp camera in Radiance format.
	# @author German Molina	
	# @version 0.2
	# @param camera [Camera] A SketchUp Camera object
	# @return [String]
	# @example Export the actual view
	#   File.open("/Certain/Directory/view.vf",'w'){|f|
	#		f.write(self.getViewString(Sketchup.active_model.active_view.camera))
	#	}
	# @todo This is not a good method actually... there are much more options for views on Radiance.
	#   some work should be done here in order to get it working correctly.	
	def self.getViewString(camera)	
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
	# @return [Void]
	# @example Export the actual view
	#   GH_Exporter.exportView(path)	
	def self.export_views(path)
		system("mkdir "+path+"Views")
		path=path+'Views'+GH_OS.slash
		#Export the actual view
		File.open(path+'view.vf','w'){|f|
			f.write(self.getViewString(Sketchup.active_model.active_view.camera))
		}
		#then the scenes
		pages=Sketchup.active_model.pages
		if pages.count>=1 then
			pages.each do |page|
				File.open(path+page.name.tr(" ","_")+'.vf','w'){|f|
					f.write(self.getViewString(page.camera))
				}
			end
		end
	
	end

	# Export the window groups. This method is called from #{exportFaces}. Creates a Window folder within the directory.
	# @author German Molina	
	# @version 1.1
	# @param path [String] Directory to export the Window Groups.
	# @param windows [faces] A directory with windows, selected during #{exportFaces}.
	# @return [Void]	
	def self.write_window_groups(path,windows)
		system("mkdir "+path+"Windows")
		
		groups=GH_Utilities.get_win_groups(windows)
		ngroups=groups.length
		nwin=1 #this will count the windows
		s=GH_OS.slash
		writers=[]
		groups.each do |gr|
			writers=writers+[File.open(path+'Windows'+s+gr+'.rad','w')]
		end

		windows.each do |win|
			c=GH_Labeler.get_win_group(win)
			info=self.get_rad_string(win,true)
			if c!=nil then # if the window has a group
				# We write using the writer of that group
				i=0
				while i<ngroups
					if c==groups[i] then #if the group of the window is the same as the one in the array
						writers[i].write('#normal (points inside): '+win.normal.x.to_s+' '+win.normal.y.to_s+' '+win.normal.z.to_s+"\n")
						writers[i].write('WinMat'+info[0])
#						writers[i].write(info[1].name+' '+info[0])
						break # we leave the loop
					end
					i+=1
				end
			
			else #if not
				#we write using a new writer
				winname=win.get_attribute("Groundhog","Name")
				if winname==nil then
					wr=File.open(path+'Windows'+s+'WindowSet_'+nwin.to_s+'.rad','w')
					nwin=nwin+1
				else 
					wr=File.open(path+'Windows'+s+winname+'.rad','w')
				end
				wr.write('WinMat '+info[0])
				wr.close	
			end
		end

		#Close the rest of the files
		writers.each do |w|
			w.close
		end
	end

	# Writes the sensors that are over the workplanes. Creates a Workplanes folder on the directory.
	#
	# The prompt will ask for the spacing, and a .pts file will be written on the path on the Workplanes folder.
	#
	# The name of the file will be the name of the entity.
	# @author German Molina	
	# @version 1.0
	# @param path [String] Directory to export the Window Groups.
	# @param entities [entities] Array of workplanes.
	# @return [Void]
	# @note This method assumes that it receives workplanes (which are horizontal surfaces). If there is a not-horizontal
	#   surface in the array, sensors and spacing will make no sense.
	# @todo Allow non-horizontal workplanes?
	def self.write_sensors(path,entities)

		system("mkdir "+path+"Workplanes")
		
		if entities.length>0 then #we export this only if there is any workplane	
			path=path+GH_OS.slash+'Workplanes'+GH_OS.slash
			prompts=["Workplane Sensor Spacing (m)"]
			defaults=[0.3]
			sys=UI.inputbox prompts, defaults, "Spacing of the sensors on workplanes?"
			d=sys[0].m

			entities.each do |ent| #for all the entities (which are faces)
				if GH_Labeler.workplane?(ent) then #Only workplanes
					name=GH_Labeler.get_name(ent).tr(" ","_") #Get the name of the surface
					pts=[] #Create an array with all the points 
					b=ent.bounds
					max=b.max
					min=b.min
					max_x=max.x
					max_y=max.y
					x=min.x
					y=min.y
					z=min.z
					while x<max_x do #loop over all the face
						while y<max_y do
							pt=Geom::Point3d.new(x,y,z)
							if ent.classify_point(pt)==1 then #if the point is on the workplane
								pts=pts+[pt]
							end
							y=y+d
						end
						y=min.y #restart y.
						x=x+d
					end 
			
					File.open(path+name+'.pts','w'){ |f| #The file is opened
						pts.each do |p| #and the sensors are written
							x=p.x.to_m
							y=p.y.to_m
							z=p.z.to_m
							f.write(x.to_s+"\t"+y.to_s+"\t"+z.to_s+"\t0\t0\t1\n") 
							#this will have to change for exporting non horizontal workplanes.
						end
					}
			
				end
			end
		end
	end

	
	# Export the Radiance Modifiers
	# @author German Molina	
	# @version 1.0
	# @param path [String] Directory to export the Window Groups.
	# @param windows [faces] A directory with windows, selected during #{exportFaces}.
	# @return [Void]
	# @example Export the actual view
	#   GH_Exporter.exportView(path)	
	def self.export_modifiers(path,mat_array)
		system("mkdir "+path+"Materials")
		path=path+"Materials"+GH_OS.slash
		File.open(path+"materials.mat",'w'){ |f| #The file is opened
			unsup=0
			mat_array.each do |mat|
				matName=mat.name.tr(" ","_").tr("#","_")
				matPath=GH_OS.rad_material_path+matName+".mat"
				if File.exist?(matPath) then #write the information.
					File.open(matPath, "r").each_line do |line|
					  f.write(line)
					end
					f.write("\n\n")
				else
					unsup+=1
					if mat.texture==nil then
						color=mat.color
					else
						color=mat.texture.average_color
					end					
					r=color.red/255.0
					g=color.green/255.0
					b=color.blue/255.0

					f.write("## unsupported Material\n\n")
					if mat.alpha < 1 then #then this is a glass
						r=r*mat.alpha #This is physically wrong... but it does give the appereance
						g=g*mat.alpha
						b=b*mat.alpha
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s
						f.write("void\tglass\t"+matName+"\n0\n0\n3\t"+rgb+"\n")
					else #This is an opaque material 
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s+"\t0\t0"						
						f.write("void\tplastic\t"+matName+"\n0\n0\n5\t"+rgb+"\n")
					end
					f.write("\n\n")
				end
			end	
		}
	end
	

	# Export the Scene file. The Scene file references the different Radiance files to create the model.
	# @author German Molina	
	# @version 0.7
	# @param path [String] Directory to export the scene file
	# @return [Void]	
	def self.write_scene_file(path)
		File.open(path+"scene.rad",'w'){ |f| #The file is opened
			f.write("###############\n## Scene exported using Groundhog v"+Sketchup.extensions["Groundhog"].version.to_s+" in SketchUp "+Sketchup.version+"\n## Date of export: "+Time.now.to_s+"\n###############\n")
			
			f.write("\n\n\n###### DEFAULT SKY \n\n")			
			f.write(self.default_sky)
			
			f.write("\n\n\n###### GEOMETRY \n\n")
			
			Sketchup.active_model.layers.each do |layer|
				name=layer.name.tr(" ","_")
				f.write("!xform ./Geometry/"+name+".rad\n")
			end

			f.write("\n\n\n###### COMPONENT INSTANCES \n\n")
			defi=Sketchup.active_model.definitions
			defi.purge_unused
			defi.each do |h|
				if h.is_a? Sketchup::ComponentDefinition then
					hName=h.name.tr(" ","_").tr("#","_") # The "#" symbol starts comments in Radiance.
					instances=h.instances
					instances.each do |inst|
						if inst.parent.is_a? Sketchup::Model then #write only "first level" components
							f.write(self.get_component_string(" ./Components/",inst,hName))						
						end
					end		
				end
			end		

			
		}
	end

	def self.default_sky
		info=Sketchup.active_model.shadow_info
		sun=info["SunDirection"]
		floor=Geom::Vector3d.new(sun.x, sun.y, 0)
		alt=sun.angle_between(floor).radians
		azi=floor.angle_between(Geom::Vector3d.new(0,-1,0)).radians
		azi=-azi if sun.x>0
		return "!gensky -ang #{alt} #{azi} +s\n\n"+self.sky_complement
	end
	
	def self.sky_complement
		return 	"skyfunc\tglow\tskyglow\n0\n0\n4\t0.99\t0.99\t1.1\t0\n\nskyglow\tsource\tskyball\n0\n0\n4\t0\t0\t1\t360\n\n"
	end
	
	# Export the ComponentDefinitions into separate files into "Components" folder.
	# Each file is autocontained, although some materials might be repeated in the "materials.mat" file.
	# @author German Molina	
	# @version 0.1
	# @param path [String] Directory to export the model (scene file)
	# @return [Void]	
	def self.export_component_definitions(path)
		defi=Sketchup.active_model.definitions
		defi.purge_unused

		return if defi.count == 0 #better dont do anything if there are no components
		
		s=GH_OS.slash
		system("mkdir "+path+"Components")
		path=path+"Components"+s
	
		defi.each do |h|
			next if h.image? # or h.group? 
			
			entities=h.entities
			faces=GH_Utilities.get_all_layer_faces(entities,[])
			instances=GH_Utilities.get_component_instances(entities)
			
			geom_string=""	
			instances.each do |inst| #include the nested components
				geom_string=geom_string+self.get_component_string(" ./",inst,inst.definition.name.tr(" ","_").tr("#","_"))
			end
			geom_string+="\n\n"
						
			mat_array=[] 
			faces.each do |fc| #then the rest of the faces
				next if GH_Labeler.workplane? (fc) or GH_Labeler.illum? (fc) or GH_Labeler.window? (fc)
				
				info=self.get_rad_string(fc,false)
				geom_string=geom_string+info[1].name.tr(" ","_")+info[0]
				mat_array=mat_array+[info[1]]
			end
			mat_array.uniq!
			mat_string=""
			
			
			
			unsup=0
			mat_array.each do |mat| #THIS IS REPEATED FROM ANOTHER METHOD!!!
				matName=mat.name.tr(" ","_").tr("#","_")
				matPath=GH_OS.rad_material_path+matName+".mat"
				if File.exist?(matPath) then #write the information.
					File.open(matPath, "r").each_line do |line|
					  mat_string=mat_string+line
					end
					mat_string=mat_string+"\n\n"
				else
					unsup+=1
					if mat.texture==nil then
						color=mat.color
					else
						color=mat.texture.average_color
					end					
					r=color.red/255.0
					g=color.green/255.0
					b=color.blue/255.0

					mat_string=mat_string+"## unsupported Material\n\n"
					if mat.alpha < 1 then #then this is a glass
						r=r*mat.alpha #This is probably wrong... but it does the job.
						g=g*mat.alpha
						b=b*mat.alpha
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s
						mat_string=mat_string+"void\tglass\t"+matName+"\n0\n0\n3\t"+rgb+"\n"
					else #This is an opaque material 
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s+"\t0\t0"						
						mat_string=mat_string+"void\tplastic\t"+matName+"\n0\n0\n5\t"+rgb+"\n"
					end
					mat_string=mat_string+"\n\n"
				end
			end
			hName=h.name.tr(" ","_").tr("#","_") # The "#" symbol starts comments in Radiance.
			File.open(path+hName+".rad",'w'){ |f|
				f.write mat_string+geom_string
			}				

		end	#end for each
	end #end method
	
	# Returns the String that has to be written in the scene file... !xform etc.
	# @author German Molina	
	# @version 0.4
	# @param comp [Sketchup::ComponentInstance]
	# @return xform comand [string]
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
	
	
end #end class