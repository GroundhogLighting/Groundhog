module IGD
	module Groundhog
		module Config

			@@config=Hash.new()

			# ALL POSSIBLE OPTIONS MUST BE HERE
			@@default_config = {
				"DESIRED_PIXEL_AREA" => 0.25,
				"ALBEDO" => 0.2,
				"RVU" => "-ab 3",
				"RCONTRIB" => "-ab 4 -ad 512 -lw 1e-3",
				"RTRACE" => "-ab 4 -ad 512 -lw 1e-3",
				"LUMINAIRE_SHAPE_THRESHOLD" => 1.7,
				"TERRAIN_OVERSIZE" => 4,
				"TDD_DAYLIGHT_RFLUXMTX" => "-ab 4 -ad 128 -lw 1e-3",
				"TDD_VIEW_RFLUXMTX" => "-ab 4 -ad 512 -lw 1e-3",
				"TDD_PIPE_RFLUXMTX" => "-ab 4 -ad 128 -lw 1e-3",
				"PROJECT_NAME" => nil,
				"EARLY" => 8.0,
				"LATE" => 18.0,
				"MIN_ILLUMINANCE" => 300,
				"MAX_ILLUMINANCE" => 2000,
				"DYNAMIC_CALCULATION_METHOD" => "DC",
				"STATIC_CALCULATION_METHOD" => "RTRACE",
				"STATIC_SKY_BINS" => 1,
				"DYNAMIC_SKY_BINS" => 1,
				"TDD_SINGLEDAYMTX" => "true",
				"TDD_PIPE_REFLECTANCE" => 0.95,
			}

			# Returns the HASH with the Configurations... this is meant to be accessed by other modules
			# @author German Molina
			# @return [Hash] The configuration
			def self.get_config
				@@config
			end

			# Returns the value asked... it checks within the CONFIG first. If
			#   it is not there, the DEFAULT values will be used
			# @author German Molina
			# @return [String] The configuration
			# @param key [String] The key to be searched in the config
			def self.get_element(key)
				ret = @@config[key]
				ret = @@default_config[key] if ret == nil
				ret = false if ret == nil
				UI.messagebox("Trying to get '#{key}', which is not set neither defaulted in the Configuration") if not ret
				return ret
			end


			# Saves the config files where it belongs
			# @author German Molina
			def self.write_config_file
				path=self.config_path
				File.open(path,'w+'){ |f|
					f.write(@@config.to_json)
				}
			end

			# Returns the desired pixel area in m2
			# @author German Molina
			# @return [Numeric] The desired pixel area
			def self.desired_pixel_area
				self.get_element("DESIRED_PIXEL_AREA").to_f
			end

			# Returns the desired options for ray-tracing within a TDD pipe
			# @author German Molina
			# @return [String] The selected options
			def self.tdd_pipe_rfluxmtx
				self.get_element("TDD_PIPE_RFLUXMTX")
			end

			# Returns the desired options for ray-tracing for a TDD view matrix
			# @author German Molina
			# @return [String] The selected options
			def self.tdd_view_rfluxmtx
				self.get_element("TDD_VIEW_RFLUXMTX")
			end

			# Returns the desired options for a TDD pipe reflectance
			# @author German Molina
			# @return [String] The selected options
			def self.tdd_pipe_reflectance
				self.get_element("TDD_PIPE_REFLECTANCE")
			end

			# Returns the desired options for ray-tracing for a TDD daylight matrix
			# @author German Molina
			# @return [String] The selected options
			def self.tdd_daylight_rfluxmtx
				self.get_element("TDD_DAYLIGHT_RFLUXMTX")
			end


			# Asks for a EPW or WEA file to be inputed.
			# @author German Molina
			# @return [String] The weather file path, False if not
			def self.ask_for_weather_file
				path = UI.openpanel("Choose a weather file", "c:/", "weather file (.epw, .wea) | *.epw; *.wea ||")
				return false if not path

				while path.split('.').pop!='epw' do
					UI.messagebox("Invalid file extension. Please input a WEA or EPW file")
					path = UI.openpanel("Choose a weather file", path, "*.epw; *.wea")
					return false if not path
				end

				return path
			end

			# Gets the path where the Radiance programs are installed.
			# @author German Molina
			# @return [String] The radiance bin path
			def self.radiance_path
				"#{OS.main_groundhog_path}/src/Radiance/bin"
			end

			# Adds the Radiance Path and the Raypath to the environmental variables.
			# @author German Molina
			def self.setup_radiance
				# ADD RADIANCE_PATH
				if Config.radiance_path then
					divider = ":"
					divider = ";" if OS.getsystem == "WIN"
					ENV["PATH"]=Config.radiance_path+divider << ENV["PATH"]
					ENV["RAYPATH"] = "#{Config.raypath}"
				else
					UI.messagebox "There was a problem loading Radiance"
				end
			end

			# Gets the path where the Radiance library is installed
			# @author German Molina
			# @return [String] The radiance bin path
			def self.raypath
				"#{OS.main_groundhog_path}/src/Radiance/lib"
			end

			# Gets the path where the weather files are supposed to be stored... must be configured by the user.
			# @author German Molina
			# @return [Depends] The weather path if successful, nil (false) if not.
			def self.weather_path
				path = @@config["WEATHER_PATH"]
				return false if path ==""
				return false if path == nil
				return path
			end

			# Gets the albedo
			# @author German Molina
			# @return [String] The albedo
			def self.albedo
				self.get_element("ALBEDO")
			end

			# Gets the terrain oversize parameter
			# @author German Molina
			# @return [String] The terrain oversize param
			def self.terrain_oversize
				self.get_element("TERRAIN_OVERSIZE").to_f
			end

			# Opens, reads and parses a weather file. The file gets fixed into the model
			# @author German Molina
			# @param path [String] the path to the weather file
			# @return void
			def self.set_weather(path)
				return false if not path
				if Sketchup.active_model.georeferenced? then
					result = UI.messagebox('This model is already georeferenced. Choosing a weather file will overwrite this location.Do you want to continue?', MB_YESNO)
					return false if result == IDNO
				end
				weather = Weather.parse_epw(path)
				Sketchup.active_model.set_attribute("Groundhog","Weather",weather.to_json)
				shadow_info = Sketchup.active_model.shadow_info
				shadow_info["City"]=weather["city"]
				shadow_info["Country"] = weather["country"]
				shadow_info["Latitude"] = weather["latitude"]
				shadow_info["Longitude"] = weather["longitude"]
				shadow_info["TZOffset"] = weather["timezone"]

				return true
			end

			# Sets the list of active addons
			# @author German Molina
			# @param msg [String] The names of the active add-ons separated by commas
			# @return void
			def self.set_active_addons(msg)
				 @@config["ACTIVE_ADDONS"] = msg
				#write the rad file
				self.write_config_file
			end

			# returns the list of active addons
			# @author German Molina
			# @return [Array<String>] An array with the names of the active addons
			def self.active_addons
				return @@config["ACTIVE_ADDONS"].split(",") if @@config["ACTIVE_ADDONS"]
				return []
			end


			# Gets the preconfigured RVU options for previsualization
			# @author German Molina
			# @return [String] The options
			def self.rvu_options
				self.get_element("RVU")
			end

			# Gets the Annual calculation method
			# @author German Molina
			# @return [String] The method
			def self.dynamic_calculation_method
				self.get_element("DYNAMIC_CALCULATION_METHOD")
			end

			# Gets the Static calculation method
			# @author German Molina
			# @return [String] The method
			def self.static_calculation_method
				self.get_element("STATIC_CALCULATION_METHOD")
			end

			# Gets the reinhart subdivition for dynamic simulation
			# @author German Molina
			# @return [Number] The reinhart subdivition
			def self.dynamic_sky_bins
				self.get_element("DYNAMIC_SKY_BINS")
			end

			# Gets the reinhart subdivition for static simulation
			# @author German Molina
			# @return [Number] The reinhart subdivition
			def self.static_sky_bins
				self.get_element("STATIC_SKY_BINS")
			end

			# Gets the preconfigured RTRACE options for calculations
			# @author German Molina
			# @return [String] The options
			def self.rtrace_options
				self.get_element("RTRACE")
			end

			# Gets the preconfigured RCONTRIB options for calculations
			# @author German Molina
			# @return [String] The options
			def self.rcontrib_options
				self.get_element("RCONTRIB")
			end

			# Gets the preconfigured Luminaire Shape Threshold
			# @author German Molina
			# @return [String] The threshold
			def self.luminaire_shape_threshold
				self.get_element("LUMINAIRE_SHAPE_THRESHOLD")
			end


			# Gets the spacing between workplane sensors
			# @author German Molina
			# @return [Float] Sensor Spacing
			def self.desired_pixel_area
				self.get_element("DESIRED_PIXEL_AREA").to_f
			end


			# Gets the early working hour (i.e. when people start working)
			# @author German Molina
			# @return [Float] Early
			def self.early
				self.get_element("EARLY").to_f
			end

			# Gets the late working hour (i.e. when people stop working)
			# @author German Molina
			# @return [Float] Late
			def self.late
				self.get_element("LATE").to_f
			end

			# Gets the minimum target illuminance
			# @author German Molina
			# @return [Float] Minimum illuminance
			def self.min_illuminance
				self.get_element("MIN_ILLUMINANCE").to_f
			end

			# Gets the maximum target illuminance
			# @author German Molina
			# @return [Float] Maximum illuminance
			def self.max_illuminance
				self.get_element("MAX_ILLUMINANCE").to_f
			end


			# Loads the configuration file into the configuration hash.
			# If the file does not exist, it ask you to fill it.
			# @author German Molina
			# @return void
			def self.load_config
				path=self.config_path
				@@config=JSON.parse(File.open(path).read)

				#include add-ons
				Addons.load_addons(self.active_addons)

				return true
			end

			# Returns the path where the config file is stored.
			#
			# @author German Molina
			# @return [String] Configuration file path
			# @version 0.1
			def self.config_path
				"#{OS.main_groundhog_path}/config"
			end

			# Returns true if
			#
			# @author German Molina
			# @return [String] Configuration file path
			# @version 0.1
			def self.tdd_singledaymtx
				ret = self.get_element("TDD_SINGLEDAYMTX")
				return true if ret == "true"
				return false if ret == "false"
			end



			# Opens the configuration web dialog and adds the appropriate action_callback
			#
			# @author German Molina
			# @return [Boolean] success
			# @version 0.4
			def self.show_config

				config_path=self.config_path

				wd=UI::WebDialog.new(
					"Preferences", false, "",
					595, 490, 100, 100, true )

				wd.set_file("#{OS.main_groundhog_path}/src/html/preferences.html" )
				wd.show


				wd.add_action_callback("onLoad") do |web_dialog,msg|
					script=""
					@@default_config.each do |field|
						id = field[0].downcase
						script += Utilities.set_element_value(id,@@config,field[1])
					end
					weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
					if weather != nil then
						weather = JSON.parse(weather)
						script += "document.getElementById('weather_city').innerHTML='#{weather["city"]}';"
						script += "document.getElementById('weather_state').innerHTML='#{weather["state"]}';"
						script += "document.getElementById('weather_country').innerHTML='#{weather["country"]}';"
						script += "document.getElementById('weather_latitude').innerHTML='#{weather["latitude"]}';"
						script += "document.getElementById('weather_longitude').innerHTML='#{weather["longitude"]}';"
						script += "document.getElementById('weather_timezone').innerHTML='GMT #{weather["timezone"]}';"
					end
					script+="if(document.getElementById('tdd_singledaymtx').value == 'true'){document.getElementById('tdd_singledaymtx').checked=true;}"
					web_dialog.execute_script(script);
				end

				wd.set_on_close{
					@@default_config.each do |field|
						id = field[0].downcase
						@@config[field[0]] = wd.get_element_value(id).strip
					end
					self.write_config_file
				}


				wd.add_action_callback("set_weather_path") do |web_dialog,msg|
					path = self.ask_for_weather_file
					self.set_weather(path)
					weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
					if weather != nil then
						weather = JSON.parse(weather)
						script = "document.getElementById('weather_city').innerHTML='#{weather["city"]}';"
						script += "document.getElementById('weather_state').innerHTML='#{weather["state"]}';"
						script += "document.getElementById('weather_country').innerHTML='#{weather["country"]}';"
						script += "document.getElementById('weather_latitude').innerHTML='#{weather["latitude"]}';"
						script += "document.getElementById('weather_longitude').innerHTML='#{weather["longitude"]}';"
						script += "document.getElementById('weather_timezone').innerHTML='GMT #{weather["timezone"]}';"
						web_dialog.execute_script(script)
					end
				end

			end



		end
	end
end
