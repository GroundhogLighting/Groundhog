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
			# @param options [Hash] The options
			# @return [Boolean] Success
			def self.calc_UDI(options)
				path=OS.tmp_groundhog_path
				FileUtils.cd(path) do
					return false if not OS.execute_script(self.calc_annual_illuminance(options))
					wps=Dir["Workplanes/*.pts"]

					wps.each do |workplane| #calculate UDI for each workplane
						info=workplane.split("/")
						name=info[1].split(".")[0]
						values=Results.annual_to_UDI("#{OS.tmp_groundhog_path}/Results/#{name}_DC.txt", "#{OS.tmp_groundhog_path}/Workplanes/#{name}.pts", options["lower_threshold"], options["upper_threshold"], options["early"], options["late"])
						return if not values #if the format was wrong, for example

						pixels = Utilities.readTextFile("#{OS.tmp_groundhog_path}/Workplanes/#{name}.pxl",",",0)
						metric = "U.D.I"
						metric = "Daylight Authonomy" if options["upper_threshold"] > 9e15
						Results.draw_pixels(values,pixels,name,metric)
						min_max=Results.get_min_max_from_model
						Results.update_pixel_colors(0,min_max[1])	#minimum is 0 by default
					end
				end
				return true
			end

			# Calculates and plots the Daylight Autonomy
			# @author German Molina
			# @param options [Hash] The options
			# @return [Boolean] Success
			def self.calc_DA(options)
				options["upper_threshold"] = 9e16
				options["lower_threshold"] = options["threshold"]
				return self.calc_UDI(options)
			end


			# Calculates the annual illuminance using a chosen method
			# @author German Molina
			# @param options [Hash] A hash with the options (method, bins)
			# @return [Boolean] Success
			def self.calc_annual_illuminance(options)
				path=OS.tmp_groundhog_path
				script=[]

				FileUtils.cd(path) do
					file=Config.weather_path

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
					case options["method"]
					when "DC"
						dc=self.calc_DC(options["bins"])
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
						script << "#{OS.program("gendaymtx")} -m #{options["bins"]} #{weaname}.wea | dctimestep DC/#{name}.dmx | rmtxop -fa - | rcollate -ho -oc 1 | rcalc -e '$1=179*(0.265*$1+0.67*$2+0.065*$3)' > Results/#{name}_DC.txt" if OS.getsystem=="MAC"
						#WIN
						script << "#{OS.program("gendaymtx")} -m #{options["bins"]} #{weaname}.wea | dctimestep DC/#{name}.dmx | rmtxop -fa - | rcollate -ho -oc 1 | rcalc -e \"$1=179*(0.265*$1+0.67*$2+0.065*$3)\" > Results/#{name}_DC.txt" if OS.getsystem=="WIN"
					end
				end
				return script
			end


			# Exports the files and creates the script for calculating the simplest DC
			# @author German Molina
			# @param bins [Integer] The sky subdivition
			# @return [Array<String>] The Script if success, false if not.
			def self.calc_DC(bins)
				path=OS.tmp_groundhog_path

				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					OS.mkdir("DC")

					#modify sky
					File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
						f.write(Exporter.white_sky(bins))
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
			def self.actual_illuminance(options)
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
							f.write("!gensky -ang #{alt} #{azi} #{options["sky"]} -g #{options["ground_rho"]}\n\n")
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
						f.write("!gensky -ang 45 0 -c -B 55.86592\n\n")
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

			def self.show_sim_wizard
				wd=UI::WebDialog.new(
					"Simulation wizard", false, "",
					595, 490, 100, 100, false )

				wd.set_file("#{OS.main_groundhog_path}/src/html/simulation.html" )

				wd.add_action_callback("load_views") do |web_dialog,msg|
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
					web_dialog.execute_script(script)
				end

				wd.add_action_callback("rvu") do |web_dialog,msg|
					next if not OS.ask_about_Radiance
					next if not Exporter.export(OS.tmp_groundhog_path, true)
					FileUtils.cd(OS.tmp_groundhog_path) do
						begin
							OS.execute_script(self.rvu(msg))
							OS.clear_actual_path
						rescue
							UI.messagebox "There was a problem when trying to RVU your model."
						end
					end

				end

				wd.add_action_callback("calc_DF") do |web_dialog,msg|
					next if not OS.ask_about_Radiance
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

							results.each do |res|
								Results.import_results("#{OS.tmp_groundhog_path}/Results/#{res}.txt","Daylight factor")
							end
							#OS.clear_actual_path

						rescue
							UI.messagebox "There was a problem when trying to calculate the Daylight Factor."
						end
					end

				end

				wd.add_action_callback("calc_actual_illuminance") do |web_dialog,msg|
					next if not OS.ask_about_Radiance
					next if not Exporter.export(OS.tmp_groundhog_path,true)
					options=JSON.parse(msg)
					FileUtils.cd(OS.tmp_groundhog_path) do
						begin
							OS.mkdir("Results")
							OS.execute_script(self.actual_illuminance(options))
							wps=Dir["Workplanes/*.pts"]
							results=[]
							wps.each do |workplane|
								info=workplane.split("/")
								name=info[1].split(".")[0]
								results << name
							end

							results.each do |res|
								Results.import_results("#{OS.tmp_groundhog_path}/Results/#{res}.txt","Illuminance")
							end
							OS.clear_actual_path
						rescue
							UI.messagebox "There was a problem when trying to calculate the Actual Illuminance."
						end
					end
				end

				wd.add_action_callback("calc_DA") do |web_dialog,msg|
					next if not OS.ask_about_Radiance
					next if not Exporter.export(OS.tmp_groundhog_path, false)
					options=JSON.parse(msg)
					self.calc_DA(options)
				end

				wd.add_action_callback("calc_UDI") do |web_dialog,msg|
					next if not OS.ask_about_Radiance
					next if not Exporter.export(OS.tmp_groundhog_path, false)
					options=JSON.parse(msg)
					self.calc_UDI(options)
				end

				wd.show()
			end


		end #end class
	end #end module
end
