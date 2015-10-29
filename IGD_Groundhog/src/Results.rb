module IGD
	module Groundhog
		# This class is meant to help importing results from a grid into a Workplane.

		module Results


			# Converts sensor results into a 2D array
			#
			# It expects the grid be in format "Px Py Pz Value"
			# where the first three terms are the position in space,
			# and the 4th value is the actual value to be put in the grid.
			#
			# The positions are assumed to be in meters.
			#
			# @author German Molina
			# @param results_path [String] the path to the results file
			# @return [Depends] An array with the values when succesful, "false" if not.
			# @version 0.2
			def self.results_to_array(results_path)
				if not File.exist?(results_path) then
					UI.messagebox("Results file not found.")
					return false
				end

				ret=[]
				line_num=1
				File.open(results_path, "r").each_line do |line|
					line.strip!
					data=line.split("\t")
					if data.length==4 then #check the correct format
						ret=ret+[[data[0].to_f.m, data[1].to_f.m, data[2].to_f.m, data[3].to_f]]
					else
						UI.messagebox("Incorrect results file format at line"+line_num.to_s)
						return false
					end
					line_num+=1
				end

				return ret
			end

			# Converts a very long file of annual results into a 2d array for
			# plotting as a heatmap of UDI.
			#
			# It reads the workplane path for getting the position of each sensor.
			#
			# The positions are assumed to be in meters.
			#
			# @author German Molina
			# @param results_path [String] the path to the results file
			# @param workplane_file [String] the path to the workplane file
			# @param min [Float] The minimum acceptable illuminance
			# @param max [Float] The maximum acceptable illuminance
			# @return [Depends] An array with the values when succesful, "false" if not.
			# @version 0.1
			def self.annual_to_UDI(results_path, workplane_file, min, max, early, late)

				return false if not File.exist?(results_path)
				return false if not File.exist?(workplane_file)

				results=File.open(results_path).read.split("\n").collect!{|x| x.to_f}
				n_results=results.length

				sensors=File.open(workplane_file).read.split("\n")
				n_sensors=sensors.length

				n_samples = n_results/n_sensors
				warn "Weather file does not seem to have 8760 hours!!" if n_samples != 8760

				timestep=8760.0/n_samples

				ret=[]
				sensors.each do |line|
					line.strip!
					sensor=line.split("\t")
					ret=ret+[[sensor[0].to_f.m, sensor[1].to_f.m, sensor[2].to_f.m, 0]]
				end

				#they alternate hour
				ret.each do |sensor|
					time=timestep/2.0
					ac=0.0
					for i in 1..n_samples
						time+=timestep
						ill=results.shift
						next if (time%24.0) < early or (time%24.0) > late
						ac+=1.0
						next if ill > max
						next if ill < min
						sensor[3]+=100.0
					end
					sensor[3]/=ac
				end

				return ret
			end

			# Converts a very long file of annual results into a 2d array for
			# plotting as a heatmap for plotting DA>
			#
			# It reads the workplane path for getting the position of each sensor.
			#
			# The positions are assumed to be in meters.
			#
			# @author German Molina
			# @param results_path [String] the path to the results file
			# @param workplane_file [String] the path to the workplane file
			# @param min [Float] The minimum acceptable illuminance
			# @return [Depends] An array with the values when succesful, "false" if not.
			# @version 0.1
			def self.annual_to_DA(results_path, workplane_file, min, early, late)

				return false if not File.exist?(results_path)
				return false if not File.exist?(workplane_file)

				results=File.open(results_path).read.split("\n").collect!{|x| x.to_f}
				n_results=results.length

				sensors=File.open(workplane_file).read.split("\n")
				n_sensors=sensors.length

				n_samples = n_results/n_sensors
				warn "Weather file does not seem to have 8760 hours!!" if n_samples != 8760

				timestep=8760.0/n_samples

				ret=[]
				sensors.each do |line|
					line.strip!
					sensor=line.split("\t")
					ret=ret+[[sensor[0].to_f.m, sensor[1].to_f.m, sensor[2].to_f.m, 0]]
				end

				#they alternate hour
				ret.each do |sensor|
					time=timestep/2.0
					ac=0.0
					for i in 1..n_samples
						time+=timestep
						ill=results.shift
						next if (time%24.0) < early or (time%24.0) > late
						ac+=1.0
						next if ill < min
						sensor[3]+=100.0
					end
					sensor[3]/=ac
				end

				return ret
			end

			# Calculates the u and v vectors for drawing the "pixels" in the solved workplanes.
			#
			# This method was thought to be used along with "results_to_array"
			# and, accordingly, that array is the parameter it receives.
			#
			# This method assumes that the sensors have a certain order... that is, written
			# as Groundhog writes them. First, all sensors in direction V, then
			# shift one U to the side, and again all sensors in direction V.
			#
			# @author German Molina
			# @param array [Array<Float>] a 2d array with 4 columns
			# @return [Array<Geom::Vector3d>] an array of Geom::Vector3d objects
			# @version 0.1
			def self.get_UV(array)
				#Start with the first two points
				data0=array[0]
				data=array[1]

				#get V... easy. Two sequencial points
				pt0=Geom::Point3d.new(data0[0],data0[1],data0[2])
				pt=Geom::Point3d.new(data[0],data[1],data[2])
				v=pt0.vector_to(pt)

				u=v
				i=2
				#Now, for getting U, we need to check the moment when we shift one "U"
				while u.parallel?(v) do
					data=array[i]
					pt=Geom::Point3d.new(data[0],data[1],data[2])
					u=pt0.vector_to(pt)
					i+=1
				end


				return [u,v]
			end




			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# The normal of the plane as well as the dimension of the pixels
			# are calculated from the position of the sensors. It is assumed that
			# all the sensors lie in the same plane point in the same direction.
			#
			# @author German Molina
			# @param u [vector3d] U vector
			# @param v [vector3d] V vector
			# @param array [array] The array (2D, 4 columns) with the data to show.
			# @param name [String] The name that will be given to the group that contains the pixels
			# @return [Void]
			# @version 0.2
			def self.draw_pixels(u,v,array,name)
				model=Sketchup.active_model
				op_name="Draw pixels"
				begin
					model.start_operation(op_name,true)

					group = Sketchup.active_model.entities.add_group
					group.name=name

					entities=group.entities


					#we move half step to each side.
					u.transform!(0.5)
					v.transform!(0.5)

					max=0
					min=9999999999999
					array.each do |data|
						min=data[3] if min>data[3]
						max=data[3] if max<data[3]
					end

					#draw every line. Each pixel is a quadrilateral.
					array.each do |data|
						pt=Geom::Point3d.new(data[0],data[1],data[2])
						vertex1=pt.offset(v).offset(u)
						vertex4=pt.offset(v.transform(-1)).offset(u)
						vertex3=pt.offset(v.transform(-1)).offset(u.transform(-1))
						vertex2=pt.offset(v).offset(u.transform(-1))

						pixel=entities.add_face(vertex1,vertex2,vertex3,vertex4)
						Labeler.to_result_pixel(pixel)
						Labeler.set_pixel_value(pixel,data[3])

					end

					Labeler.to_solved_workplane(group)
					Labeler.set_workplane_value(group,min,max)
					group.casts_shadows=false
					model.commit_operation
				rescue => e
					model.abort_operation
					OS.failed_operation_message(op_name)
				#else
				  #
				  # Do code here ONLY if NO errors occur.
				  #
				#ensure
				  #
				  # ALWAYS do code here errors or not.
				  #
				end

			end


			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# @author German Molina
			# @param value  [float] The value to be assigned a color
			# @param max [float] The maximum value, the one that saturates the color scale.
			# @param min [float] The min value, the one that saturates the color scale.
			# @return [Array<Float>] with Red, Green and Blue components
			# @version 0.3
			def self.get_pixel_color(value,max,min)

				red=[0.18848,0.05468174,0.00103547,8.311144e-08,7.449763e-06,0.0004390987,0.001367254,0.003076,0.01376382,0.06170773,0.1739422,0.2881156,0.3299725,0.3552663,0.372552,0.3921184,0.4363976,0.6102754,0.7757267,0.9087369,1,1,0.9863]
				green=[0.0009766,2.35501e-05,0.0008966244,0.0264977,0.1256843,0.2865799,0.4247083,0.4739468,0.4402732,0.3671876,0.2629843,0.1725325,0.1206819,0.07316644,0.03761026,0.01612362,0.004773749,6.830967e-06,0.00803605,0.1008085,0.3106831,0.6447838,0.9707]
				blue=[0.2666,0.3638662,0.4770437,0.5131397,0.5363797,0.5193677,0.4085123,0.1702815,0.05314236,0.05194055,0.08564082,0.09881395,0.08324373,0.06072902,0.0391076,0.02315354,0.01284458,0.005184709,0.001691774,2.432735e-05,1.212949e-05,0.006659406,0.02539]
				nbins=red.length-1 #the number of color bins

				return [red[0],green[0],blue[0]] if value <= min
				return [red[nbins],green[nbins],blue[nbins]] if value >= max or (max-min)<1e-3

				max=max-min
				value=value-min
				min=0

				norm_value=value/max
				bin_value=norm_value*nbins
				under_bin=bin_value.floor
				upper_bin=bin_value.ceil

				r=red[under_bin]+(bin_value-under_bin)*(red[upper_bin]-red[under_bin])
				g=green[under_bin]+(bin_value-under_bin)*(green[upper_bin]-green[under_bin])
				b=blue[under_bin]+(bin_value-under_bin)*(blue[upper_bin]-blue[under_bin])

				return [r,g,b]
			end

			# Update the pixel colors of all the solved_workplanes in the model.
			#
			# @author German Molina
			# @param max [Float] the maximum value for the scale
			# @param min [Float] the minimum value for the scale
			# @return void
			# @version 0.1
			def self.update_pixel_colors(min,max)
				model=Sketchup.active_model
				op_name="Update pixels"
				begin
					model.start_operation(op_name,true)

					entities=Sketchup.active_model.entities

					entities.each do |ent|
						next if not Labeler.solved_workplane?(ent)
						#now we are sure this is a solved_workplane

						ent.entities.each do |pixel|
							next if not Labeler.face?(pixel) or not Labeler.result_pixel?(pixel)
							# now we are sure ent is a pixel.
							value=Labeler.get_value(pixel)

							color=self.get_pixel_color(value,max,min)
							pixel.material=color
							pixel.back_material=color

						end

					end
					model.commit_operation

				rescue => e
					model.abort_operation
					OS.failed_operation_message(op_name)
				#else
				  #
				  # Do code here ONLY if NO errors occur.
				  #
				#ensure
				  #
				  # ALWAYS do code here errors or not.
				  #
				end
			end

			# Checks all the solved workplanes in the model
			# and gets the minimum and maximum values from all of them
			#
			# @author German Molina
			# @return [Array<Float>] An array with the minimum and maximum values
			# @version 0.1
			def self.get_min_max_from_model
				definitions=Sketchup.active_model.definitions
				#Get the maximum and minimum in the whole model
				max=-1
				min=9999999999999
				definitions.each do |defi|
					defi.instances.each do |inst|
						next if not Labeler.solved_workplane?(inst)
						#now we are sure this is a solved_workplane
						min_max=Labeler.get_value(inst)

						min=min_max[0] if min > min_max[0]
						max=min_max[1] if max < min_max[1]
					end
				end
				return [min,max]
			end

			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# @author German Molina
			# @param path [String]
			# @return void
			# @version 0.1
			def self.import_results(path)

				model=Sketchup.active_model
				name=path.tr("\\","/").split("/").pop.split(".")[0]
				array=self.results_to_array(path)
				return if not array #if the format was wrong, for example

				uv=self.get_UV(array)
				self.draw_pixels(uv[0],uv[1],array,name)
				min_max=self.get_min_max_from_model
				self.update_pixel_colors(0,min_max[1])	#minimum is 0 by default

			end

			# Opens the "Scale Handler" web dialog and adds the appropriate action_callback
			#
			# @author German Molina
			# @return [Void]
			# @version 0.1
			def self.show_scale_handler

				wd=UI::WebDialog.new(
					"Scale handler", false, "",
					180, 380, 100, 100, false )

				wd.set_file("#{OS.main_groundhog_path}/src/html/scale.html" )

				wd.add_action_callback("update_scale") do |web_dialog,msg|
					scale=JSON.parse(msg)
					min=scale["min"]
					max=scale["max"]
					#check if there is any auto
					if(min<0 or max<0) then
						min_max=Results.get_min_max_from_model
						min=min_max[0] if min<0
						max=min_max[1] if max<0
					end


					Results.update_pixel_colors(min,max)

					web_dialog.execute_script("document.getElementById('min').value="+min.to_i.to_s+";document.getElementById('max').value="+max.to_i.to_s+";");
				end

				wd.show()

			end




		end
	end #end module
end
