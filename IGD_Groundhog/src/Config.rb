module IGD
	module Groundhog
		module Config

			@@config=Hash.new()

			# ALL POSSIBLE OPTIONS MUST BE HERE
			@@default_config = {
				"DESIRED_PIXEL_AREA" => 0.25,
				"ALBEDO" => 0.2,
				"RADIANCE_PATH" => nil,
				"WEATHER_PATH" => nil,
				"RVU" => "-ab 3",
				"RCONTRIB" => "-ab 4 -ad 512",
				"RTRACE" => "-ab 4 -ad 512",
				"LUMINAIRE_SHAPE_THRESHOLD" => 1.7,
				"TERRAIN_OVERSIZE" => 4,
				"TDD_PIPE_RFLUXMTX" => "-ab 9 -ad 1024",
			}

			# Returns the HASH with the Configurations... this is meant to be accessed by other modules
			# @author German Molina
			# @return [Hash] The configuration
			def self.get_config
				@@config
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
				@@config["DESIRED_PIXEL_AREA"].to_f
			end

			# Returns the desired options for ray-tracing within a TDD pipe
			# @author German Molina
			# @return [String] The selected options
			def self.tdd_pipe_rfluxmtx
				@@config["TDD_PIPE_RFLUXMTX"]
			end


			# Asks for a EPW or WEA file to be inputed.
			# @author German Molina
			# @return [String] The weather file path, False if not
			def self.ask_for_weather_file
				path = @@config["WEATHER_PATH"]
				if path then
					path=path.split("/")
					path.pop
					path=path.join("/")
				else
					path="c:/"
				end
				path = UI.openpanel("Choose a weather file", path, "weather file (.epw, .wea) | *.epw; *.wea ||")
				return false if not path
				#return path.tr("\\","/") if not check

				while path.split('.').pop!='epw' and path.split('.').pop!='wea' do
					UI.messagebox("Invalid file extension. Please input a WEA or EPW file")
					path = UI.openpanel("Choose a weather file", path, "*.epw; *.wea")
					return false if not path
				end

				return path.tr("\\","/")
			end

			# Gets the path where the Radiance programs are installed... must be configured by the user.
			# @author German Molina
			# @return [String] The radiance bin path
			def self.radiance_path
				@@config["RADIANCE_PATH"]
			end

			# Gets the path where the weather files are supposed to be stored... must be configured by the user.
			# @author German Molina
			# @return [Depends] The radiance bin path if successful, nil (false) if not.
			def self.weather_path
				@@config["WEATHER_PATH"]
			end

			# Gets the albedo
			# @author German Molina
			# @return [String] The albedo
			def self.albedo
				@@config["ALBEDO"]
			end

			# Gets the terrain oversize parameter
			# @author German Molina
			# @return [String] The terrain oversize param
			def self.terrain_oversize
				@@config["TERRAIN_OVERSIZE"].to_f
			end

			# Sets the path where the weather files are supposed to be stored... must be configured by the user.
			# @author German Molina
			# @param path [String] the path
			# @return void
			def self.set_weather_path(path)
				 @@config["WEATHER_PATH"] = path
				#write the rad file
				self.write_config_file
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
				@@config["RVU"]
			end

			# Gets the preconfigured RTRACE options for calculations
			# @author German Molina
			# @return [String] The options
			def self.rtrace_options
				@@config["RTRACE"]
			end

			# Gets the preconfigured RCONTRIB options for calculations
			# @author German Molina
			# @return [String] The options
			def self.rcontrib_options
				@@config["RCONTRIB"]
			end

			# Gets the preconfigured Luminaire Shape Threshold
			# @author German Molina
			# @return [String] The threshold
			def self.luminaire_shape_threshold
				return @@config["LUMINAIRE_SHAPE_THRESHOLD"].to_f if @@config["LUMINAIRE_SHAPE_THRESHOLD"]!= nil
				return @@default_config["LUMINAIRE_SHAPE_THRESHOLD"].to_f
			end



			# Gets the spacing between workplane sensors
			# @author German Molina
			# @return [Float] Sensor Spacing
			def self.sensor_spacing
				return @@config["SENSOR_SPACING"].to_f
			end


			# Loads the configuration file into the configuration hash.
			# If the file does not exist, it ask you to fill it.
			# @author German Molina
			# @return void
			def self.load_config
				path=self.config_path

				#add radiance path
				@@config=JSON.parse(File.open(path).read)
				ENV["PATH"]=Config.radiance_path+":" << ENV["PATH"] if Config.radiance_path

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
				return "#{OS.main_groundhog_path}/config"
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
					510, 470, 100, 100, false )

				wd.set_file("#{OS.main_groundhog_path}/src/html/preferences.html" )
				wd.show


				wd.add_action_callback("onLoad") do |web_dialog,msg|
					script=""
					@@default_config.each do |field|
						id = field[0].downcase
						script += Utilities.set_element_value(id,@@config,field[1])
					end
					web_dialog.execute_script(script);
				end

				wd.set_on_close{
					old_path=@@config["RADIANCE_PATH"]

					@@default_config.each do |field|
						id = field[0].downcase
						@@config[field[0]] = wd.get_element_value(id).strip
					end


					#CHECK VALUES
					if OS.check_Radiance_Path(@@config["RADIANCE_PATH"]) then
						#update the Radiance path
						if old_path != nil and old_path != "" then
							ENV["PATH"]=ENV["PATH"].split(old_path).join(Config.radiance_path) #erase the old one and replace it
						else
							ENV["PATH"]=Config.radiance_path+":" << ENV["PATH"]
						end
					else
						UI.messagebox("WARNING:\n\nRadiance does not seem to be where you told us.\n\nThe rest of your options have been saved.")
						@@config["RADIANCE_PATH"] = @@default_config["RADIANCE_PATH"]
					end
					self.write_config_file

				}


				wd.add_action_callback("set_weather_path") do |web_dialog,msg|
					path = self.ask_for_weather_file
					if path then
						web_dialog.execute_script("document.getElementById('weather_path').value='#{path}'")
					end
				end

			end



		end
	end
end
