module IGD
	module Groundhog
		module Config

			@@rad_config=Hash.new()

			def self.get_rad_config
				@@rad_config
			end

			# Gets the path where the Radiance programs are installed... must be configured by the user.
			# @author German Molina
			# @return [String] The radiance bin path
			def self.radiance_path
				@@rad_config["RADIANCE_PATH"]
			end

			# Gets the path where the weather files are supposed to be stored... must be configured by the user.
			# @author German Molina
			# @return [Depends] The radiance bin path if successful, false if not.
			def self.weather_path
				return @@rad_config["WEATHER_PATH"] if @@rad_config["WEATHER_PATH"]!= nil
				return false
			end

			# Sets the path where the weather files are supposed to be stored... must be configured by the user.
			# @author German Molina
			# @param path [String] the path
			# @return void
			def self.set_weather_path(path)
				 @@rad_config["WEATHER_PATH"] = path
				#write the rad file
				File.open("#{OS.main_groundhog_path}/config",'w+'){ |f|
					f.write(@@rad_config.to_json)
				}
			end




			# Gets the preconfigured RVU options for previsualization
			# @author German Molina
			# @return [String] The options
			def self.rvu_options
				@@rad_config["RVU"]
			end

			# Gets the preconfigured RTRACE options for calculations
			# @author German Molina
			# @return [String] The options
			def self.rtrace_options
				@@rad_config["RTRACE"]
			end

			# Gets the preconfigured RCONTRIB options for calculations
			# @author German Molina
			# @return [String] The options
			def self.rcontrib_options
				@@rad_config["RCONTRIB"]
			end


			# Gets the spacing between workplane sensors
			# @author German Molina
			# @return [Float] Sensor Spacing
			def self.sensor_spacing
				return @@rad_config["SENSOR_SPACING"] if @@rad_config["SENSOR_SPACING"]!= nil
				prompts=["Workplane Sensor Spacing (m)"]
				defaults=[0.5]
				sys=UI.inputbox prompts, defaults, "Spacing of the sensors on workplanes?"
				return false if not sys
				return sys[0]
			end


			# Loads the configuration file into the configuration hash.
			# If the file does not exist, it ask you to fill it.
			# @author German Molina
			# @return void
			def self.load_config
				path="#{OS.main_groundhog_path}/config"
				UI.messagebox("It seems that you have not configured Groundhog yet.\nPlease do it.") if not File.exist?(path)
				if not File.exist?(path) then
					return false if not self.show_config
				end

				@@rad_config=JSON.parse(File.open(path).read)
				ENV["PATH"]=Config.radiance_path+":" << ENV["PATH"]
				return true
			end

			# Opens the configuration web dialog and adds the appropriate action_callback
			#
			# @author German Molina
			# @return [Boolean] success
			# @version 0.4
			def self.show_config

				config_path="#{OS.main_groundhog_path}/config"

				wd=UI::WebDialog.new(
					"Preferences", false, "",
					530, 450, 100, 100, false )

				wd.set_file("#{OS.main_groundhog_path}/src/html/preferences.html" )
				wd.show

				wd.add_action_callback("onLoad") do |web_dialog,msg|
					old_path=false
					if File.exists?(config_path) then
						d=JSON.parse(File.open(config_path).read)
						script=""
						script+="document.getElementById('rad_path').value='#{d['RADIANCE_PATH']}';" if d["RADIANCE_PATH"] != ""
						old_path=d["RADIANCE_PATH"] if d["RADIANCE_PATH"] != nil
						script+="document.getElementById('weather_path_input').innerHTML=' #{d['WEATHER_PATH']}';" if d["WEATHER_PATH"] != "" and d["WEATHER_PATH"] != nil
						script+="document.getElementById('rvu').value='#{d['RVU']}';" if d["RVU"] != ""
						script+="document.getElementById('rcontrib').value='#{d['RCONTRIB']}';" if d["RCONTRIB"] != ""
						script+="document.getElementById('rtrace').value='#{d['RTRACE']}';" if d["RTRACE"] != ""
						script+="document.getElementById('sensor_spacing').value='#{d['SENSOR_SPACING']}';"	 if d["SENSOR_SPACING"] != ""

						#fill defaults of them that are not specified
						script+="document.getElementById('rvu').value='-ab 3';" if d["RVU"] == ""
						script+="document.getElementById('rcontrib').value='-ab 4 -ad 1024';" if d["RCONTRIB"] == ""
						script+="document.getElementById('rtrace').value='-ab 4 -ad 1024';" if d["RTRACE"] == ""

						web_dialog.execute_script(script);
					else
						script=""
						script+="document.getElementById('rvu').value='-ab 3';"
						script+="document.getElementById('rcontrib').value='-ab 4 -ad 1024';"
						script+="document.getElementById('rtrace').value='-ab 4 -ad 1024';"

						web_dialog.execute_script(script);

					end
				end


				wd.add_action_callback("set_radiance_preferences") do |web_dialog,msg|
					config=JSON.parse(msg)

					old_path=@@rad_config["RADIANCE_PATH"]

					@@rad_config["RADIANCE_PATH"]=config["RADIANCE_PATH"]
					@@rad_config["WEATHER_PATH"]=config["WEATHER_PATH"]
					@@rad_config["RVU"]=config["RVU"]
					@@rad_config["RCONTRIB"]=config["RCONTRIB"]
					@@rad_config["RTRACE"]=config["RTRACE"]

					if OS.check_Radiance_Path(config["RADIANCE_PATH"]) then

						#write the rad file
						File.open(config_path,'w+'){ |f|
							f.write(@@rad_config.to_json)
						}

						#update the Radiance path
						if not old_path then
							ENV["PATH"]=Config.radiance_path+":" << ENV["PATH"]
						else
							ENV["PATH"]=ENV["PATH"].split(old_path).join(Config.radiance_path) #erase the old one and replace it
						end

						UI.messagebox("Preferences saved")
					else
						UI.messagebox("Radiance does not seem to be where you told us, or maybe such directory does not even exist.")
					end
				end

				wd.add_action_callback("set_general_preferences") do |web_dialog,msg|
					config=JSON.parse(msg)
					@@rad_config["SENSOR_SPACING"]=config["SENSOR_SPACING"]

					#sensor spacing is validated within the javascript

					#write the rad file
					File.open(config_path,'w+'){ |f|
						f.write(@@rad_config.to_json)
					}
					UI.messagebox("Preferences saved")
				end

				wd.add_action_callback("set_weather_path") do |web_dialog,msg|
					path = @@rad_config["WEATHER_PATH"]
					if(path!=nil) then
						path=path.split("/")
						path.pop
						path=path.join("/")
					else
						path="c:/"
					end
					path = UI.openpanel("Choose a weather file", path, "*.epw | *.wea")
					if path then
						self.set_weather_path(path)
						web_dialog.execute_script("document.getElementById('weather_path_input').innerHTML='#{path}'")
					end
				end

			end



		end
	end
end
