module IGD
	module Groundhog

		# This module intends to handle results; that is, drawing them, coloring them, etc.
		module Results

			# Returns an array with the names of the metrics within the solved-workplanes, obtained from the Solved Workplanes
			# @author German Molina
			# @return [Array <String>] An array with the names of the metrics
			def self.get_metrics_list
				Utilities.get_solved_workplanes(Sketchup.active_model.entities).map{|x| JSON.parse(Labeler.get_value(x))["metric"]}.uniq
			end

			# Returns an array with the solved workplanes in the model
			# @author German Molina
			# @return [Array <String>] An array with the names of the workplanes
			def self.get_workplane_list
				Utilities.get_solved_workplanes(Sketchup.active_model.entities)
			end

			# Returns an array with the names of the workplanes, obtained from the Solved Workplanes
			# @author German Molina
			# @return [Array <String>] An array with the names of the workplanes
			def self.get_workplane_name_list
				Utilities.get_solved_workplanes(Sketchup.active_model.entities).map{|x| JSON.parse(Labeler.get_value(x))["workplane"]}.uniq
			end




			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# If the metric is set to False, the user will be asked to
			# define one. This is useful for importing
			#
			# @author German Molina
			# @param values [array] The array (2D but 1 columns) with the data to show.
			# @param pixels [array] The array (2D) with the positions of the vertices of pixels.
			# @param workplane [String] The name of the workplane to which this is solution
			# @param objective [Hash] The objective
			# @return [Float] The percentage of approved area
			# @version 0.6
			def self.draw_pixels(values,pixels,workplane,objective)
				ret = false
				model=Sketchup.active_model
				if values.length != pixels.length then
					UI.messagebox("Number of lines in 'Pixels' and 'Values' do not match for objective '#{objective["name"]}' in workplane '#{workplane}'")						
					UI.messagebox(" N-pixels: #{pixels.length} | N-values: #{values.length} ")
					return false
				end
				#pixels need to have 3 values for each vertex
				#values need to be in one column.
				if values[0].length != 1 or pixels[0].length%3 != 0 then
					UI.messagebox("Incorrect format in 'pixels' or 'values' when drawing pixels")
					return false
				end

				op_name="Draw pixels"
				begin
					model.start_operation(op_name,true)

					#delete previous workplane.
					Utilities.get_solved_workplanes(Sketchup.active_model.entities).select{|x|
						JSON.parse(Labeler.get_value(x))["objective"]==objective["name"]
					}.select {|x|
						JSON.parse(Labeler.get_value(x))["workplane"]==workplane
					}.each{|x|
						x.erase!
					}

					group = Sketchup.active_model.entities.add_group
					group.name="#{workplane}-#{objective["name"]}"

					entities=group.entities

					#initialize minimum and maximum
					max=0
					min=9999999999999

					#draw every line. Each pixel is a polygon.
					pixels.each do |data|
						value = values.shift[0].to_f

						#check minimum and maximum
						min=value.to_f if min>value.to_f
						max=value.to_f if max<value.to_f

						vertex=[]
						nvertices = data.length/3
						nvertices.times do
							v1 = data.shift.to_f
							v2 = data.shift.to_f
							v3 = data.shift.to_f
							vertex.push [v1.m, v2.m, v3.m]
						end
=begin
						# This is for avoiding the error of "points are not planar" that
						# is thrown when points are too close.
						too_small=false
						vertex.each_with_index{|v,index|
							vp=vertex[index-1]
							d=Math.sqrt((vp[0]-v[0])**2+(vp[1]-v[1])**2+(vp[2]-v[2])**2)
							too_small = true if d<=1e-3 #this is SketchUp's tolerance in inches
						}
						next if too_small
=end
						pixel=entities.add_face(vertex)
						Labeler.to_result_pixel(pixel)
						Labeler.set_pixel_value(pixel,value)
					end

					Labeler.to_solved_workplane(group)
					Labeler.to_solved_workplane(group.definition)
					wp_value = self.get_workplane_statistics(group, objective)
					wp_value["objective"] = objective["name"]
					wp_value["workplane"] = workplane
					ret = wp_value["approved_percentage"]
					Labeler.set_workplane_value(group,wp_value.to_json)

					group.casts_shadows=false
					group.receives_shadows=true

					#hide the edges
					group.entities.select{|x| x.is_a? Sketchup::Edge}.each{|x| x.hidden=true}

					model.commit_operation
				rescue Exception => ex
					UI.messagebox ex
					model.abort_operation
					raise ex
				end
				return ret
			end


			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model. The color is obtained from the default Radiance
			# color scale.
			#
			# @author German Molina
			# @param value  [float] The value to be assigned a color
			# @param max [float] The maximum value, the one that saturates the color scale.
			# @param min [float] The min value, the one that saturates the color scale.
			# @return [Array<Float>] with Red, Green and Blue components
			# @version 0.3
			def self.get_rad_pixel_color(value,max,min)

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

			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model. The color is obtained from the groundhog
			# color scale, which intends to clearly show which pixels are over-valued,
			# sub-valued and correctly-values
			#
			# @author German Molina
			# @param value  [float] The value to be assigned a color
			# @param max [float] The maximum value, the one that saturates the color scale.
			# @param min [float] The min value, the one that saturates the color scale.
			# @return [Array<Float>] with Red, Green and Blue components
			# @version 0.3
			def self.get_gh_pixel_color(value,min,good_min, good_max, max)
				three_ranges = true
				if not good_max then
				 	good_max = max
					three_ranges = false
				end

				if [min, good_min, good_max, max].sort != [min, good_min, good_max, max] then
					UI.messagebox "Trying to find a pixel color with incorrect values."
					return false
				end


				max_color = [189,6,5]
				min_color = [70,116,196]
				good_min_color = [255,255,255]
				good_max_color = [249, 190, 6]

				if value <= min then
					return min_color
				elsif value > min and value <= good_min then
					ret = min_color
					frac = (value.to_f - min.to_f)/(good_min.to_f - min.to_f)
					sum = good_min_color
				elsif value > good_min and value <= good_max then
					ret = good_min_color
					frac = (value.to_f - good_min.to_f)/(good_max.to_f - good_min.to_f)
					sum = good_max_color
				elsif value > good_max and value <= max then
					ret = good_max_color
					frac = (value.to_f - good_max.to_f)/(max.to_f - good_max.to_f)
					sum = max_color
				elsif value > max
					if three_ranges then
						return max_color
					else
						return good_max_color
					end
				end
				ret.each_with_index{|val,i| ret[i]+= frac * (sum[i]-ret[i])}
				return ret.map{|x| x/255.0}
			end

			# Update the pixel colors of all the solved_workplanes in the model.
			#
			# @author German Molina
			# @param max [Float] the maximum value for the scale
			# @param min [Float] the minimum value for the scale
			# @param objective [Hash] The objective to which we change the color
			# @return void
			# @version 0.2
			def self.update_pixel_colors(min,max,objective)
				model=Sketchup.active_model
				op_name="Update pixels"
				begin
					model.start_operation(op_name,true)
					
					#good_min and good_max are assign for static metrics, by default
					# If the static metric does not have "good_light" field, it is
					# assumed to be binary... that is, 0 is bad, > 0 is good.
					good_min = 1e-9
					good_max = 9e16
					if objective.key? "good_light" then
						good_min = objective["good_light"]["min"]
						good_max = objective["good_light"]["max"]
						good_max = 9e16 if not good_max
					end
					#if dynamic, we actually just want to get the good pixels
					if objective["dynamic"] then
						good_min = objective["good_pixel"]
						good_max = 9e16
					end
					workplanes=Utilities.get_solved_workplanes(Sketchup.active_model.entities)
					workplanes = workplanes.select{|x| JSON.parse(Labeler.get_value(x))["objective"]==objective["name"]}
					workplanes.each do |workplane|
						workplane.entities.each do |pixel|
							next if not Labeler.face?(pixel) or not Labeler.result_pixel?(pixel)
							# now we are sure ent is a pixel.
							value=Labeler.get_value(pixel)
							color=self.get_rad_pixel_color(value,max,min)
							#color=self.get_rad_pixel_color(value,min,good_min,good_max,max)
							pixel.material=color
							pixel.back_material=color
						end
						wp_value=JSON.parse(Labeler.get_value(workplane))
						wp_value["scale_min"]=min
						wp_value["scale_max"]=max
						Labeler.set_workplane_value(workplane,wp_value.to_json)
					end
					model.commit_operation

				rescue Exception => ex
					UI.messagebox ex
					model.abort_operation
					raise ex
				end
			end

			# Checks all the solved workplanes in the model that correspond to a metric
			# and gets the minimum and maximum values from all of them
			#
			# @author German Molina
			# @return [Array<Float>] An array with the minimum and maximum values
			# @param objective [String] The name of the objetive that we are getting the min and max from
			# @version 0.2
			def self.get_min_max_from_model(objective)
				workplanes = Utilities.get_solved_workplanes(Sketchup.active_model.entities)
				#Get the maximum and minimum in the whole model
				max=-1
				min=9999999999999
				workplanes = workplanes.select{|x| JSON.parse(Labeler.get_value x)["objective"]==objective}
				workplanes.each do |inst|
					value=JSON.parse(Labeler.get_value(inst))
					min=value["min"] if min > value["min"]
					max=value["max"] if max < value["max"]
				end
				return [min,max]
			end

			# Checks all the solved workplanes in the model that correspond to a metric
			# and gets the minimum and maximum values from their scale
			#
			# @author German Molina
			# @return [Array<Float>] An array with the minimum and maximum values
			# @param objective [String] The objective that we are getting the min and max from
			# @version 0.1
			def self.get_scale_from_model(objective)
				workplanes = Utilities.get_solved_workplanes(Sketchup.active_model.entities)
				workplanes = workplanes.select{|x| JSON.parse(Labeler.get_value x)["objective"]==objective["name"]}
				scale_min=false
				scale_max=false
				workplanes.each do |workplane|
					value=JSON.parse(Labeler.get_value(workplane))
					if not scale_min then
						scale_min = value["scale_min"]
						scale_max = value["scale_max"]
					else
						if value["scale_min"] != scale_min or value["scale_max"] != scale_max then
							UI.messagebox("Workplanes of the same objective have different scales!\nWe will fix that now")
							min_max=Results.get_min_max_from_model(objective["name"])
							Results.update_pixel_colors(0,min_max[1],objective)	#minimum is 0 by default
							self.get_scale_from_model(objective)
						end
					end
				end
				return [scale_min,scale_max]
			end



			# Reads the results from a grid, and represent them as a heat map
			# in a plane in the model.
			#
			# @author German Molina
			# @param path [String] the path to the values to import
			# @param pixels_file [String] the path to the pixels corresponding to the values
			# @param workplane [String] the workplane that correspond to this solution
			# @param objective [Hash] the objective imported
			# @return [Float] The percentage of approved area
			# @version 0.3
			def self.import_results(path,pixels_file,workplane,objective)

				values = Utilities.readTextFile(path,",",0)
				return if not values #if the format was wrong, for example

				if not File.exist?(pixels_file) then
					UI.messagebox("Pixels file '#{pixels_file}' not found.")
					return false
				end

				pixels = Utilities.readTextFile(pixels_file,",",0)
				
				return self.draw_pixels(values,pixels,workplane,objective)
			end


			# Calculates statistical data from a solved workplane
			#
			# @author German Molina
			# @return [Hash] A hash with statistics
			# @param wp [Workplane] The workplane to analyze
			# @param objective [Hash] The objective
			# @version 0.1
			def self.get_workplane_statistics(wp, objective)
				return false if not Labeler.solved_workplane? wp

				if objective["dynamic"] then
					return self.get_dynamic_objective_workplane_statistics(wp,objective)
				else 
					return self.get_static_objective_workplane_statistics(wp,objective)
				end				
			end

			# Calculates the statistic of a workplane with dynamic objective
			#
			# @author German Molina
			# @return [Hash] A hash with statistics
			# @param wp [Workplane] The workplane to analyze
			# @param objective [Hash] The objective
			# @version 0.1
			def self.get_dynamic_objective_workplane_statistics(wp,objective)
				
				pixels = wp.entities.select{|x| Labeler.result_pixel? x}			
				count=pixels.length
				sum=0
				total_area = 0
				max=Labeler.get_value(pixels[0])
				min=max
				good_area = 0;
				pixels.each do |pixel|
					value = Labeler.get_value(pixel)
					area = pixel.area					
					good_area += area if value >= objective["good_pixel"]
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
				ret["goal"]=objective["goal"]
				ret["min_over_average"] = min==average ? 1 : min/average
				ret["min_over_max"] = min==max ? 1 : min/max #fully shaded planes get a Max and Min of 0.
				ret["nsensors"] = count
				ret["approved_percentage"] = good_area / total_area
				ret["total_area"] = total_area/1550.0 #transform into square meters from sqin
				return ret
			end

			# Calculates the statistic of a workplane with static objective
			#
			# @author German Molina
			# @return [Hash] A hash with statistics
			# @param wp [Workplane] The workplane to analyze
			# @param objective [Hash] The objective
			# @version 0.1
			def self.get_static_objective_workplane_statistics(wp,objective)
				
				pixels = wp.entities.select{|x| Labeler.result_pixel? x}


				#good_min and good_max are assign for static metrics, by default
				# If the static metric does not have "good_light" field, it is
				# assumed to be binary... that is, 0 is bad, > 0 is good.
				good_min = 1e-9 #just over 0... so 0 is "not approved"
				good_max = 9e16
				if objective.key? "good_light" then
					good_min = objective["good_light"]["min"]
					good_max = objective["good_light"]["max"] 
					good_max = 9e16 if not good_max
					good_min = 0 if not good_min
				end
		

				count=pixels.length
				sum=0
				total_area = 0
				max=Labeler.get_value(pixels[0])
				min=max
				good_area = 0;
				pixels.each do |pixel|
					value = Labeler.get_value(pixel)
					area = pixel.area
					good_area += area if value >= good_min and value <= good_max
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
				ret["goal"]=objective["goal"]
				ret["min_over_average"] = min==average ? 1 : min/average
				ret["min_over_max"] = min==max ? 1 : min/max #fully shaded planes get a Max and Min of 0.
				ret["nsensors"] = count
				ret["approved_percentage"] = good_area / total_area
				ret["total_area"] = total_area/1550.0 #transform into square meters from sqin
				return ret
			end


		end
	end #end module
end
