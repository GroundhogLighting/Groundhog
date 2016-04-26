module IGD
	module Groundhog
		module Rad
			#This module calls Radiance for performing calculations

			def self.gather_windows
				winstring=Dir["Windows/*"]
				if winstring.length > 0 then
					return  "./"+winstring.join(" ./").tr("\\","/")
				end
				return ""
			end

			# Calculates and plots the UDI
			# @author German Molina
			# @param da [Boolean] Parameter that sais if we are calculating DA or UDI.
			# @return [Boolean] Success
			def self.calc_UDI(da)
				path=OS.tmp_groundhog_path
				FileUtils.cd(path) do
					return false if not OS.execute_script(self.calc_annual_illuminance)
					wps=Dir["Workplanes/*.pts"]
					max = Config.max_illuminance
					max = 9e16 if da #basically, ignore this threshold
					wps.each do |workplane| #calculate UDI for each workplane
						info=workplane.split("/")
						name=info[1].split(".")[0]
						values=Results.annual_to_UDI("#{OS.tmp_groundhog_path}/Results/#{name}_DC.txt", "#{OS.tmp_groundhog_path}/Workplanes/#{name}.pts", Config.min_illuminance, max, Config.early, Config.late)
						return if not values #if the format was wrong, for example

						pixels = Utilities.readTextFile("#{OS.tmp_groundhog_path}/Workplanes/#{name}.pxl",",",0)
						metric = "U.D.I."
						metric = "Daylight authonomy" if da
						Results.draw_pixels(values,pixels,name.tr("_"," "),metric)
						min_max=Results.get_min_max_from_model(metric)
						Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
					end
				end
				return true
			end

			# Calculates and plots the Daylight Autonomy
			# @author German Molina
			# @return [Boolean] Success
			def self.calc_DA
				self.calc_UDI(true)
			end


			# Calculates the annual illuminance using a chosen method
			# @author German Molina
			# @return [Boolean] Success
			def self.calc_annual_illuminance
				path=OS.tmp_groundhog_path
				script=[]

				FileUtils.cd(path) do
					file=Config.weather_path
					file = Config.ask_for_weather_file if not file
					file = file.gsub(" ","\\ ")

					#if it is nil or (not epw and not wea)
					if not file or (file.split(".").pop!='wea' and file.split(".").pop != 'epw') then
						file = Config.ask_for_weather_file
						return false if not file
					end

					extension = file.split(".").pop
					weaname = file.tr("//","/").split("/").pop.split(".").shift
					script << "#{OS.program("epw2wea")} #{file} #{weaname}.wea" if extension=="epw"
					FileUtils.cp(file,"#{weaname}.wea") if extension=="wea"

					#Calculate DC matrices
					case Config.annual_calculation_method
					when "DC"
						dc=self.calc_DC
						return false if not dc
						script += dc
					else
						UI.messagebox "Calculation method not recognized when trying to calculate the Annual Illuminance"
						return false
					end

					#Simulate
					wps=Dir["Workplanes/*.pts"]

					OS.mkdir("Results")
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						#OSX
						script << "#{OS.program("gendaymtx")} -m #{Config.sky_bins} -g #{Config.albedo} #{Config.albedo} #{Config.albedo} #{weaname}.wea | dctimestep DC/#{name}.dmx | rmtxop -fa - | rcollate -ho -oc 1 | rcalc -e '$1=179*(0.265*$1+0.67*$2+0.065*$3)' > Results/#{name}_DC.txt" if OS.getsystem=="MAC"
						#WIN
						script << "#{OS.program("gendaymtx")} -m #{Config.sky_bins} -g #{Config.albedo} #{Config.albedo} #{Config.albedo} #{weaname}.wea | dctimestep DC/#{name}.dmx | rmtxop -fa - | rcollate -ho -oc 1 | rcalc -e \"$1=179*(0.265*$1+0.67*$2+0.065*$3)\" > Results/#{name}_DC.txt" if OS.getsystem=="WIN"
					end
				end
				return script
			end


			# Exports the files and creates the script for calculating the simplest DC
			# @author German Molina
			# @return [Array<String>] The Script if success, false if not.
			def self.calc_DC
				path=OS.tmp_groundhog_path

				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					OS.mkdir("DC")

					#modify sky
					File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
						f.write(Exporter.white_sky(Config.sky_bins))
					}


					#build the script
					script=[]

					wps=Dir["Workplanes/*.pts"]
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]						
						script << "#{OS.program("rfluxmtx")} -I+ #{Config.rcontrib_options} < #{workplane} - Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/#{name}.dmx"

					end

					return script
				end
			end



			# Writes the files and return the script for calculating the Actual illuminance
			# @author German Molina
			# @param options [Hash] A Hash with the sky type and the ground reflectance
			# @return [Array<String>] Script if succesfull, false if not.
			def self.instant_illuminance(options)
				path=OS.tmp_groundhog_path
				script=[]

				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					#sky can change from the wizard
					info=Sketchup.active_model.shadow_info
					sun=info["SunDirection"]
					floor=Geom::Vector3d.new(sun.x, sun.y, 0)
					alt=sun.angle_between(floor).radians
					azi=floor.angle_between(Geom::Vector3d.new(0,-1,0)).radians
					azi=-azi if sun.x>0
					if alt >= 3 then
						File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
							f.write("!gensky -ang #{alt} #{azi} #{options["sky"]} -g #{Config.albedo}\n\n")
							f.write(Exporter.sky_complement)
						}
					end

					script << "#{OS.program("oconv")} ./Materials/materials.mat ./scene.rad ./Skies/sky.rad #{self.gather_windows} > octree.oct"

					wps=Dir["Workplanes/*.pts"]
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						#for OSX
						script << "#{OS.program("rtrace")} -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e '$1=179*(0.265*$4+0.67*$5+0.065*$6)' >> Results/#{name}.txt" if OS.getsystem=="MAC"
						#for Windows
						script << "#{OS.program("rtrace")} -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e \"$1=179*(0.265*$4+0.67*$5+0.065*$6)\" >> Results/#{name}.txt" if OS.getsystem=="WIN"
					end

				end
				return script
			end

			# Writes the files and return the script for calculating the Daylight Factor
			# @author German Molina
			# @return [Array<String>] Script... FALSE if not success
			def self.daylight_factor
				path=OS.tmp_groundhog_path
				script=[]
				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					#modify sky
					File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
						f.write("!gensky -ang 45 40 -c -B 55.86592 -g #{Config.albedo}\n\n")
						f.write("skyfunc glow skyglow\n0\n0\n4 1 1 1 0\n\nskyglow source skyball\n0\n0\n 4 0 0 1 360")
					}

					#oconv
					script << "#{OS.program("oconv")} ./Materials/materials.mat ./scene.rad #{self.gather_windows}  ./Skies/sky.rad  > octree.oct"

					wps=Dir["Workplanes/*.pts"]
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						#for OSX
						script << "#{OS.program("rtrace")} -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e '$1=179*(0.265*$4+0.67*$5+0.065*$6)/100' >> Results/#{name}.txt" if OS.getsystem=="MAC"
						#for Windows
						script << "#{OS.program("rtrace")} -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e \"$1=179*(0.265*$4+0.67*$5+0.065*$6)/100\" >> Results/#{name}.txt" if OS.getsystem=="WIN"
					end

				end
				return script
			end

			# Creates the script for calling RVU and previewing the model
			# @author German Molina
			# @param msg [String] json with the options
			# @return [Array<String>] Script
			def self.rvu(msg)
				options=JSON.parse(msg)
				scene = options["scene"]
				path=OS.tmp_groundhog_path

				#success=false
				script=[] #
				FileUtils.cd(path) do
					script=[]

					#oconv
					script << "#{OS.program("oconv")} ./Materials/materials.mat ./scene.rad  ./Skies/sky.rad  #{self.gather_windows} > octree.oct"
					script << "#{OS.program("rvu")} #{Config.rvu_options} -vf Views/#{scene}.vf octree.oct"
				end
				return script
			end



			# Returns the javascript for loading the Scenes (Pages) into the GUI
			# for previsualization
			# @author German Molina
			# @return [String] Script
			def self.load_views
				script = "var select = document.getElementById('rvu_scene');"
				script += "var option =  document.createElement('option');"
				script += "option.value = 'view';"
				script += "option.text = 'actual view';"
				script += "select.add(option);"

				Sketchup.active_model.pages.each do |page|
					name = page.name
					value = Utilities.fix_name(name)
					script += "var option =  document.createElement('option');"
					script += "option.value = '#{value}';"
					script += "option.text = '#{name}';"
					script += "select.add(option);"
				end
				return script
			end

			@@default_metrics = {
				"Review" => {:action => "rvu()", :html => "<h2>Review model</h2><fieldset><legend>Scene to review</legend><select id='rvu_scene'></select></fieldset><p align='center'><button onclick='load_rvu_views()'>Refresh views</button> <button onclick='rvu()'>Review </button></p>"},
				"Instant illuminance" => {:action => "calc_instant_illuminance()", :html => "<h2>Instant illuminance</h2><fieldset><legend>Sky model</legend><select id='instant_illuminance_sky'><option value='-u'>CIE Uniform</option><option value='-c'>CIE Overcast</option><option value='+i'>CIE Intermediate</option><option value='+s'>CIE Clear</option></select><div class='option_info'>?<div class='tooltip'><p>The sun's position is obtained from the SketchUp model.</p></div></div></fieldset><p align='center'> <button onclick='calc_instant_illuminance()'> Calculate </button></p><table align='center'><tr><td id='instant_illuminance_scale_min'></td><td><img align='center' src='images/scale_horizontal.png' alt='scale' style='width:200px;height:30px'></td><td id='instant_illuminance_scale_max'></td></tr></table><table id='instant_illuminance_results' class='with_border'></table>"},
				"Daylight factor" => {:action => "calc_DF()"},
				"Daylight authonomy" => {:action => "calc_DA()"},
				"U.D.I." => {:action => "calc_UDI()"}
			}

			# Returns the javascript for adding a metric to the GUI
			# @author German Molina
			# @param metric [String] the metric to add
			# @return [String] Script
			def self.add_metric(metric)
				fixed_name = Utilities.fix_name(metric).downcase
				directives = @@default_metrics[metric]

				#the tab first
				script  = "var tabs = document.getElementById('tabs');"
				script += "var li = document.createElement('li');"
				script += "li.innerHTML=\"<a href='\##{fixed_name}'>#{metric}</a>\";"
				script += "li.setAttribute('class','selected');" if metric == @@default_metrics.keys[0]
				script += "li.onclick = function(){select_metric('#{metric}')};"
				script += "tabs.appendChild(li);"

				#then the content
				script += "var div = document.createElement('div');"
				script += "div.setAttribute('id','#{fixed_name}');"
				script += "div.setAttribute('class','tabContent hide');"
				script += "div.setAttribute('class','tabContent');" if metric == @@default_metrics.keys[0]

				button = ""
				button = "<p align='center'><button onclick='#{directives[:action]}'> Calculate </button></p>" if directives != nil and directives[:action] != nil

				inner_html="<h2>#{metric}</h2>#{button}<table align='center'><tr><td id='#{fixed_name}_scale_min'></td><td><img align='center' src='images/scale_horizontal.png' alt='scale' style='width:200px;height:30px'></td><td id='#{fixed_name}_scale_max'></td></tr></table><table id='#{fixed_name}_results' class='with_border'></table>"
				inner_html = directives[:html] if directives != nil and directives[:html] != nil

				script += "div.innerHTML = \"#{inner_html}\";"
				script += "document.body.appendChild(div);"
				return script
			end

			# Returns a script that needs to be run to update the metric results table
			# @author German Molina
			# @return [String] The javascript script that needs to be run to update the metric results table
			def self.refresh_table(metric)
				return "" if metric == "Review"
				fixed_name=Utilities.fix_name(metric).downcase

				#select workplanes with the corresponding metric
				workplanes = Results.get_workplane_list.select{|x| JSON.parse(Labeler.get_value(x))["metric"] == metric}
				return "" if workplanes.length == 0 #return if there are none.
				scale=Results.get_scale_from_model(metric)
				#get the script
				script=""
				script += "var table = document.getElementById('#{fixed_name}_results');"
				script += "table.innerHTML = '<tr><td></td><td>Average</td><td>Minimum</td><td>Maximum</td><td>Min / Average</td><td>Min / Max</td></tr>';"
				workplanes.each do |workplane|
					data = JSON.parse(Labeler.get_value(workplane))

					script += "var row = table.insertRow(-1);"
					#name
					script += "var cell = row.insertCell(0);"
					script += "cell.innerHTML='#{data["workplane"]}';"
					#Average
					script += "cell = row.insertCell(1);"
					script += "cell.innerHTML='#{data["average"].round(1)}';"
					#Minimum
					script += "cell = row.insertCell(2);"
					script += "cell.innerHTML='#{data["min"].round(1)}';"
					#Maximum
					script += "cell = row.insertCell(3);"
					script += "cell.innerHTML='#{data["max"].round(1)}';"
					#Min/Average
					script += "cell = row.insertCell(4);"
					script += "cell.innerHTML='#{data["min_over_average"].round(3)}';"
					#Min/Max
					script += "cell = row.insertCell(5);"
					script += "cell.innerHTML='#{data["min_over_max"].round(3)}';"
				end
				#update scale
				script += "document.getElementById('#{fixed_name}_scale_min').innerHTML='#{scale[0].round(0)}';"
				script += "document.getElementById('#{fixed_name}_scale_max').innerHTML='#{scale[1].round(0)}';"
				return script
			end

			# Returns the javascript for adding all the metrics to the GUI
			# @author German Molina
			# @return [String] Script
			def self.load_metrics
				script = ""
				metrics = @@default_metrics.keys + Results.get_metrics_list
				metrics.uniq!
				metrics.each {|key|
					script+= self.add_metric(key)
					script+= self.refresh_table(key)
				}

				script+="init();"
				script += self.load_views
				return script
			end

			def self.show_sim_wizard
				wd=UI::WebDialog.new(
					"Simulation wizard", false, "",
					595, 490, 100, 100, true )

				wd.set_file("#{OS.main_groundhog_path}/src/html/simulation.html" )

				wd.add_action_callback("load_views") do |web_dialog,msg|
					web_dialog.execute_script(self.load_views)
				end


				wd.add_action_callback("onLoad") do |web_dialog,msg|
					web_dialog.execute_script(self.load_metrics)
				end

				wd.add_action_callback("select_metric") do |web_dialog,msg|
					Utilities.remark_solved_workplanes(msg)
				end

				wd.add_action_callback("rvu") do |web_dialog,msg|
					next if not Exporter.export(OS.tmp_groundhog_path, true)
					FileUtils.cd(OS.tmp_groundhog_path) do
						begin
							OS.execute_script(self.rvu(msg))
							OS.clear_actual_path
						rescue Exception => ex
							UI.messagebox ex
						end
					end

				end

				wd.add_action_callback("calc_DF") do |web_dialog,msg|
					next if not Exporter.export(OS.tmp_groundhog_path,false) #lights off
					FileUtils.cd(OS.tmp_groundhog_path) do
						begin
							OS.mkdir("Results")
							OS.execute_script(self.daylight_factor)

							wps=Dir["Workplanes/*.pts"]
							results=[]
							wps.each do |workplane|
								info=workplane.split("/")
								name=info[1].split(".")[0]
								results << name
							end

							metric = "Daylight factor"
							results.each do |res|
								Results.import_results("#{OS.tmp_groundhog_path}/Results/#{res}.txt",metric)
							end
							Utilities.remark_solved_workplanes(metric)
							min_max=Results.get_min_max_from_model(metric)
							Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
							web_dialog.execute_script(self.refresh_table(metric))
						rescue Exception => ex
							UI.messagebox ex
						end
					end
				end

				wd.add_action_callback("calc_instant_illuminance") do |web_dialog,msg|					
					next if not Exporter.export(OS.tmp_groundhog_path,true)
					options=JSON.parse(msg)
					FileUtils.cd(OS.tmp_groundhog_path) do
						begin
							OS.mkdir("Results")
							OS.execute_script(self.instant_illuminance(options))
							wps=Dir["Workplanes/*.pts"]
							results=[]
							wps.each do |workplane|
								info=workplane.split("/")
								name=info[1].split(".")[0]
								results << name
							end

							metric = "Instant illuminance"
							results.each do |res|
								Results.import_results("#{OS.tmp_groundhog_path}/Results/#{res}.txt",metric)
							end
							Utilities.remark_solved_workplanes(metric)
							min_max=Results.get_min_max_from_model(metric)
							Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
							web_dialog.execute_script(self.refresh_table(metric))
						rescue Exception => ex
							UI.messagebox ex
						end
					end
				end

				wd.add_action_callback("calc_DA") do |web_dialog,msg|
					next if not Exporter.export(OS.tmp_groundhog_path, false)
					self.calc_DA
					metric = "Daylight authonomy"
					Utilities.remark_solved_workplanes(metric)
					min_max=Results.get_min_max_from_model(metric)
					Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
					web_dialog.execute_script(self.refresh_table(metric))
				end

				wd.add_action_callback("calc_UDI") do |web_dialog,msg|
					next if not Exporter.export(OS.tmp_groundhog_path, false)
					self.calc_UDI(false)
					metric="U.D.I."
					Utilities.remark_solved_workplanes(metric)
					min_max=Results.get_min_max_from_model(metric)
					Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
					web_dialog.execute_script(self.refresh_table(metric))
				end

				wd.show()
			end


		end #end class
	end #end module
end
