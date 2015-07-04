module IGD
	module Groundhog
		module Rad
			#This module calls Radiance for performing calculations

			# Calculates the UDI using the simplest DC matrix
			# @author German Molina
			# @param options [Hash] The options
			# @return [Boolean] Success
			def self.calc_UDI(options)
				return false if not OS.ask_about_Radiance
				return false if not self.calc_annual_illuminance(options)
				path=OS.tmp_groundhog_path
				FileUtils.cd(path) do
					wps=Dir["Workplanes/*"]

					wps.each do |workplane| #calculate UDI for each workplane
						info=workplane.split("/")
						name=info[1].split(".")[0]
						array=Results.annual_to_UDI("#{OS.tmp_groundhog_path}/Results/#{name}_DC.txt", "#{OS.tmp_groundhog_path}/Workplanes/#{name}.pts", options["lower_threshold"], options["upper_threshold"])
						return if not array #if the format was wrong, for example

						uv=Results.get_UV(array)
						Results.draw_pixels(uv[0],uv[1],array,name)
						min_max=Results.get_min_max_from_model
						Results.update_pixel_colors(0,min_max[1])	#minimum is 0 by default
					end
				end
				return true
			end


			# Calculates the annual illuminance using a chosen method
			# @author German Molina
			# @param options [Hash] A hash with the options (method, bins)
			# @return [Boolean] Success
			def self.calc_annual_illuminance(options)
				return false if not OS.ask_about_Radiance

				case options["method"]
				when "DC"
					return false if not self.calc_DC(options["bins"])
				else
					UI.messagebox "Calculation method not recognized when trying to calculate the Annual Illuminance"
					return false
				end

				path=OS.tmp_groundhog_path
				FileUtils.cd(path) do
					script=[]
					wps=Dir["Workplanes/*"]

					#Asks for weather file (EPW or WEA)
					weaname = false
					path=Config.weather_path
					extension=path.split(".").pop

					if extension == "wea" or extension == "epw" then
						weaname=path.tr("\\","/").split("/").pop.tr(extension,"")
					else
						path=UI.openpanel("Choose a weather file",path)
						return false if not path
						Config.set_weather_path(path)
						extension=path.split(".").pop
						UI.messagebox("Please choose a EPW or WEA file.") if extension != "wea" and extension != "epw"
						return false if extension != "wea" and extension != "epw"
						weaname=path.tr("\\","/").split("/").pop.tr(extension,"")
					end

					OS.mkdir("Results")

					#get the file... transform if needed
					script << "epw2wea #{path} #{weaname}wea" if extension=="epw"
					FileUtils.cp(path,"#{weaname}wea") if extension=="wea"

					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						#OSX
						script << "gendaymtx -m #{options["bins"]} #{weaname}wea | dctimestep DC/#{name}.dmx | rmtxop -fa - | rcollate -ho -oc 1 | rcalc -e '$1=179*(0.265*$1+0.67*$2+0.065*$3)' > Results/#{name}_DC.txt" if OS.getsystem=="MAC"
						#WIN
						script << "gendaymtx -m #{options["bins"]} #{weaname}wea | dctimestep DC/#{name}.dmx | rmtxop -fa - | rcollate -ho -oc 1 | rcalc -e \"$1=179*(0.265*$1+0.67*$2+0.065*$3)\" > Results/#{name}_DC.txt" if OS.getsystem=="WIN"
					end

					return false if not OS.execute_script(script)
					return true
				end
			end


			# Calculates the simplest DC matrix
			# @author German Molina
			# @param bins [Integer] The sky subdivition
			# @return [Boolean] Success
			def self.calc_DC(bins)
				return false if not OS.ask_about_Radiance

				path=OS.tmp_groundhog_path
				return false if not Exporter.export(path)

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

					#gather the windows
					winstring=Dir["Windows/*"].collect{|x| x.tr("\\","/").split("/")[-1]}.join(" ./Windows/")
					winstring="./Windows/#{winstring}" if winstring.length > 0
					winstring="" if winstring.length==0

					#build the script
					script=[]

					wps=Dir["Workplanes/*"]
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						script << "rfluxmtx -n 1 -I+ #{Config.rcontrib_options} < #{workplane} - Skies/sky.rad Materials/materials.mat scene.rad #{winstring} > DC/#{name}.dmx"
					end

					return OS.execute_script(script)
				end
			end


			# Calculates the illuminance in the workplanes in the scene with the sun in the current position
			# @author German Molina
			# @return [Boolean] Success
			def self.actual_illuminance
				return false if not OS.ask_about_Radiance
				path=OS.tmp_groundhog_path
				return false if not Exporter.export(path)

				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					OS.mkdir("Results")

					#modify sky
					#File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
					#	f.write("!gensky -ang 45 0 -c -B 55.86592\n\n")
					#	f.write("skyfunc glow skyglow\n0\n0\n4 1 1 1 0\n\nskyglow source skyball\n0\n0\n 4 0 0 1 360")
					#}

					#build the script
					script=[]

					#oconv
					winstring=Dir["Windows/*"].collect{|x| x.tr("\\","/").split("/")[-1]}.join(" ./Windows/")
					winstring="./Windows/#{winstring}" if winstring.length > 0
					winstring="" if winstring.length==0
					script << "oconv ./Materials/materials.mat ./scene.rad #{winstring} > octree.oct"

					wps=Dir["Workplanes/*"]
					results=[]
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						results << name
						#for OSX
						script << "rtrace -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e '$1=$1; $2=$2; $3=$3; $4=179*(0.265*$4+0.67*$5+0.065*$6)' > Results/#{name}.txt" if OS.getsystem=="MAC"
						#for Windows
						script << "rtrace -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e \"$1=$1; $2=$2; $3=$3; $4=179*(0.265*$4+0.67*$5+0.065*$6)\" > Results/#{name}.txt" if OS.getsystem=="WIN"
					end

					success=OS.execute_script(script)
					return if not success

					results.each do |res|
						Results.import_results("Results/#{res}.txt")
					end

					OS.clear_actual_path
				end
				return true
			end

			# Calculates the daylight factor for the workplanes in the scene
			# @author German Molina
			# @return [Boolean] Success
			def self.daylight_factor
				return false if not OS.ask_about_Radiance
				path=OS.tmp_groundhog_path
				return false if not Exporter.export(path)
				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					OS.mkdir("Results")

					#modify sky
					File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
						f.write("!gensky -ang 45 0 -c -B 55.86592\n\n")
						f.write("skyfunc glow skyglow\n0\n0\n4 1 1 1 0\n\nskyglow source skyball\n0\n0\n 4 0 0 1 360")
					}

					#build the script
					script=[]

					#oconv
					winstring=Dir["Windows/*"].collect{|x| x.tr("\\","/").split("/")[-1]}.join(" ./Windows/")
					winstring="./Windows/#{winstring}" if winstring.length > 0
					winstring="" if winstring.length==0
					script << "oconv ./Materials/materials.mat ./scene.rad #{winstring} > octree.oct"

					wps=Dir["Workplanes/*"]
					results=[]
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						results << name
						#for OSX
						script << "rtrace -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e '$1=$1; $2=$2; $3=$3; $4=179*(0.265*$4+0.67*$5+0.065*$6)/100' > Results/#{name}.txt" if OS.getsystem=="MAC"
						#for Windows
						script << "rtrace -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} | rcalc -e \"$1=$1; $2=$2; $3=$3; $4=179*(0.265*$4+0.67*$5+0.065*$6)/100\" > Results/#{name}.txt" if OS.getsystem=="WIN"
					end

					success=OS.execute_script(script)
					return if not success

					results.each do |res|
						Results.import_results("Results/#{res}.txt")
					end

					OS.clear_actual_path
				end
				return true
			end

			# Calls RVU for previewing the actual scene from the current view and sky.
			# @author German Molina			
			# @return [Boolean] Success
			def self.rvu
				return false if not OS.ask_about_Radiance

				path=OS.tmp_groundhog_path
				Exporter.export(path)

				success=false
				FileUtils.cd(path) do
					script=[]

					#oconv
					winstring=Dir["Windows/*"].collect{|x| x.tr("\\","/").split("/")[-1]}.join(" ./Windows/")
					winstring="./Windows/#{winstring}" if winstring.length > 0
					winstring="" if winstring.length==0
					script << "oconv ./Materials/materials.mat ./scene.rad #{winstring} > octree.oct"

					script << "rvu #{Config.rvu_options} -vf Views/view.vf octree.oct"

					success = OS.execute_script(script)
					OS.clear_actual_path
				end
				return success
			end



		end #end class
	end #end module
end
