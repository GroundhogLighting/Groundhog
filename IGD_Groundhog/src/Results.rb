module IGD
	module Groundhog
		# This class is meant to help importing results from a grid into a Workplane.

		module Results


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
			# @version 0.2
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
				#sensors.each do |line|
				#	line.strip!
				#	sensor=line.split("\t")
				#	ret=ret+[[sensor[0].to_f.m, sensor[1].to_f.m, sensor[2].to_f.m, 0]]
				#end

				#they alternate hour
				#ret.each do |sensor|
				sensors.each do |sensor|
					time=-timestep/2.0 #say, -0.5 is the time
					ac=0.0
					good = 0.0
					for i in 1..n_samples
						time+=timestep # now it will be 0.5
						ill=results.shift
						next if (time%24.0) < early or (time%24.0) > late
						ac+=1.0
						next if ill > max
						next if ill < min
						good+=100.0
					end
					ret.push([good/ac])
				end

				return ret
			end



			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# If the metric is set to False, the user will be asked to
			# define one. This is useful for importing
			#
			# @author German Molina
			# @param values [array] The array (2D but 1 columns) with the data to show.
			# @param pixels [array] The array (2D, 9 columns) with the positions of the vertices of triangles (pixels).
			# @param workplane [String] The name that will be given to the group that contains the pixels
			# @param metric [String] The name that will be given to the group that contains the pixels
			# @return [Void]
			# @version 0.5
			def self.draw_pixels(values,pixels,workplane,metric)
				model=Sketchup.active_model
				if values.length != pixels.length then
					UI.messagebox("Number of lines in 'Pixels' and 'Values' do not match")
					return false
				end
				if values[0].length != 1 or pixels[0].length != 9 then
					UI.messagebox("Incorrect format in 'pixels' or 'values' when drawing pixels")
					return false
				end

				if not metric then
					answer = UI.inputbox(["Metric name","Workplane name"],["",workplane], "What are your results?")
					return false if not answer
					workplane=answer[1]
					metric=answer[0]
				end


				op_name="Draw pixels"
				begin
					model.start_operation(op_name,true)

					#delete previous workplane.
					Utilities.get_solved_workplanes(Sketchup.active_model.entities).select{|x|
						JSON.parse(Labeler.get_value(x))["metric"]==metric
					}.select {|x|
						JSON.parse(Labeler.get_value(x))["workplane"]==workplane
					}.each{|x|
						x.erase!
					}

					group = Sketchup.active_model.entities.add_group
					group.name=name

					entities=group.entities

					#initialize minimum and maximum
					max=0
					min=9999999999999

					#draw every line. Each pixel is a triangle.
					pixels.each do |data|
						value = values.shift[0].to_f
						#check minimum and maximum
						min=value.to_f if min>value.to_f
						max=value.to_f if max<value.to_f

						vertex0=Geom::Point3d.new(data[0].to_f.m,data[1].to_f.m,data[2].to_f.m)
						vertex1=Geom::Point3d.new(data[3].to_f.m,data[4].to_f.m,data[5].to_f.m)
						vertex2=Geom::Point3d.new(data[6].to_f.m,data[7].to_f.m,data[8].to_f.m)

						pixel=entities.add_face(vertex0,vertex1,vertex2)
						Labeler.to_result_pixel(pixel)
						Labeler.set_pixel_value(pixel,value)
					end

					Labeler.to_solved_workplane(group)
					Labeler.to_solved_workplane(group.definition)
					wp_value = self.get_workplane_statistics(group)
					wp_value["metric"] = metric
					wp_value["workplane"] = workplane
					Labeler.set_workplane_value(group,wp_value.to_json)

					group.casts_shadows=false

					#hide the edges
					group.entities.select{|x| x.is_a? Sketchup::Edge}.each{|x| x.hidden=true}

					model.commit_operation
				rescue => e
					model.abort_operation
					OS.failed_operation_message(op_name)
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
			# @version 0.2
			def self.update_pixel_colors(min,max)
				model=Sketchup.active_model
				op_name="Update pixels"
				begin
					model.start_operation(op_name,true)
					Utilities.get_solved_workplanes(Sketchup.active_model.entities).each do |workplane|
						next if workplane.hidden?
						workplane.entities.each do |pixel|
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
				end
			end

			# Checks all the solved workplanes in the model
			# and gets the minimum and maximum values from all of them
			#
			# @author German Molina
			# @return [Array<Float>] An array with the minimum and maximum values
			# @version 0.2
			def self.get_min_max_from_model
				definitions=Sketchup.active_model.definitions
				#Get the maximum and minimum in the whole model
				max=-1
				min=9999999999999
				definitions.each do |defi|
					#now we are sure this is a solved_workplane
					next if not Labeler.solved_workplane?(defi)
					next if defi.instances[0].hidden?
					defi.instances.each do |inst|
						value=JSON.parse(Labeler.get_value(inst))
						min=value["min"] if min > value["min"]
						max=value["max"] if max < value["max"]
					end
				end
				return [min,max]
			end



			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# @author German Molina
			# @param path [String]
			# @param metric [String]
			# @return void
			# @version 0.3
			def self.import_results(path,metric)

				model=Sketchup.active_model
				name=path.tr("\\","/").split("/").pop.split(".")[0]
				values = Utilities.readTextFile(path,",",0)
				return if not values #if the format was wrong, for example

				pixels_file = values[0][0]
				if not File.exist?(pixels_file) then
					#Assume there is no file there.
					#Try to find the probable pixel file in the GH export.
					pixels_file = path.tr("\\","/").split("/")
					pixels_file.pop
					pixels_file.pop
					pixels_file = "#{pixels_file.join("/")}/Workplanes/#{name}.pxl"
					if not File.exist?(pixels_file) then
						#Now... if THIS does not exist, return.
						UI.messagebox("Pixels file '#{pixels_file}' not found.")
						return false
					end
				else
					values.shift #remove the name of the file
				end
				pixels = Utilities.readTextFile(pixels_file,",",0)
				name = name.tr("_"," ")
				self.draw_pixels(values,pixels,name,metric)				
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

			# Calculates statistical data from a solved workplane
			#
			# @author German Molina
			# @return [Hash] A hash with statistics
			# @param wp [Workplane] The workplane to analyze
			# @version 0.1
			def self.get_workplane_statistics(wp)
				return false if not IGD::Groundhog::Labeler.solved_workplane? wp
				pixels = wp.entities.select{|x| IGD::Groundhog::Labeler.result_pixel? x}

				count=pixels.length
				sum=0
				total_area = 0
				max=IGD::Groundhog::Labeler.get_value(pixels[0])
				min=max

				pixels.each do |pixel|
					value = IGD::Groundhog::Labeler.get_value(pixel)
					area = pixel.area
					max = value if value > max
					min = value if value < min
					sum += value*area
					total_area += area
				end
				average = sum/total_area
				ret = Hash.new

				ret["min"] = min
				ret["max"] = max
				ret["average"]=average
				ret["min_over_average"] = min/average
				ret["min_over_max"] = min/max
				ret["nsensors"] = count
				ret["total_area"] = total_area/1550.0 #transform into square meters from sqin
				return ret
			end


		end
	end #end module
end
