module IGD
	module Groundhog
		# This module handles (loads and provides) the options that are chosen by the user
		# that are meant to be saved across projects.
		# Ray tracing options are thought to be changed on every project; so they do not 
		# belong here.
		module Config
			
			# The configuration variables are taken from here.
			@@config=Hash.new()

			# These are the default values for all the options... they 
			# are automatically copied into @config when loading or modifying.
			@@default_config = {
				"DESIRED_PIXEL_AREA" => 0.25,
				"ALBEDO" => 0.2,
				"RVU" => "-ab 3",			
				"LUMINAIRE_SHAPE_THRESHOLD" => 1.7,
				"TERRAIN_OVERSIZE" => 4,							
				"TDD_PIPE_REFLECTANCE" => 0.95,	
				"ADD_TERRAIN" => false,
				"CALC_ELUX" => false		
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
				#UI.messagebox("Trying to get '#{key}', which is not set neither defaulted in the Configuration") if not ret
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

			# Returns the desired options for a TDD pipe reflectance
			# @author German Molina
			# @return [String] The selected options
			def self.tdd_pipe_reflectance
				self.get_element("TDD_PIPE_REFLECTANCE")
			end
			

			# Gets the albedo
			# @author German Molina
			# @return [String] The albedo
			def self.albedo
				self.get_element("ALBEDO")
			end

			# Gets the luminaire shape threshold. This value is meant to control the shape of the
			# impostor light source that actually emits light.
			# The rationale behind this is that very long luminaires (i.e. fluorescent tube)
			# will not be correctly modeled by the default shape (sphere); but by a rectangle instead.
			# @author German Molina
			# @return [Float] The threshold
			def self.luminaire_shape_threshold
				self.get_element("LUMINAIRE_SHAPE_THRESHOLD").to_f
			end

			# Gets the add_terrain option
			# @author German Molina
			# @return [Boolean] The option
			def self.add_terrain				
				self.get_element("ADD_TERRAIN") == "true" or self.get_element("ADD_TERRAIN") == "TRUE" or self.get_element("ADD_TERRAIN") == true 
			end

			# Gets the calc_elux option
			# @author German Molina
			# @return [Boolean] The option
			def self.calc_elux				
				self.get_element("CALC_ELUX") == "true" or self.get_element("CALC_ELUX") == "TRUE" or self.get_element("CALC_ELUX") == true 
			end

			# Gets the terrain oversize parameter
			# @author German Molina
			# @return [String] The terrain oversize param
			def self.terrain_oversize
				self.get_element("TERRAIN_OVERSIZE").to_f
			end

	

			# Gets the preconfigured RVU options for previsualization
			# @author German Molina
			# @return [String] The options
			def self.rvu_options
				self.get_element("RVU")
			end

			# Gets the desired pixel area
			# @author German Molina
			# @return [Float] Sensor Spacing
			def self.desired_pixel_area
				self.get_element("DESIRED_PIXEL_AREA").to_f
			end


			# Loads the configuration file into the configuration hash.
			# If the file does not exist, it ask you to fill it.
			# @author German Molina
			# @return void
			def self.load_config
				path=self.config_path
				@@config=JSON.parse(File.open(path).read)
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


			# Returns the web dialog that controls the options.
			#
			# @author German Molina
			# @return [SketchUp::UI::WebDialog] the Configuration web dialog			
			def self.get
				wd = UI::WebDialog.new("Preferences", false, "Preferences",595, 490, 100, 100, true )
				wd.set_file("#{OS.main_groundhog_path}/src/html/preferences.html" )

=begin
				### COULD NOT GET THIS WORKING
				wd.add_action_callback("update") do |web_dialog,msg|
					
					version = false
					system = IGD::Groundhog::OS.getsystem
					if system == "MAC" then
						version = "macosx"
					elsif system == "WIN" then
						if Sketchup.is_64bit? then
							version="win64"
						else
							version="win32"
						end						
					end
					#if not system then
					#	UI.messagebox "Not recognized OS!"
					#	next
					#end

					final_file = "#{Sketchup.temp_dir}/Groundhog_#{version}.rbz"

					f = open(final_file,"wb")
					#begin
						Net::HTTP.start("https://github.com") { |http| #https://github.com/IGD-Labs/Groundhog/blob/master/Readme.md
							resp = http.get("/IGD-Labs/Groundhog/raw/master/Readme.md")
							#open(final_file, "wb") { |file|
								f.write(resp.body)
							#}
						}						
					#rescue
					#	UI.messagebox "Error while downloading the update!"
						#next
					#ensure
						f.close()
					#end
				end
=end

				wd.add_action_callback("follow_link") do |web_dialog,msg|
                    UI.openURL(msg)
                end

				wd.add_action_callback("check_updates") do |web_dialog,msg|
					script = ""
					# CHECK UPDATES
					date = Time.parse File.readlines("#{IGD::Groundhog::OS.main_groundhog_path}/built").shift.strip							
					
					if Sketchup.is_online then
						script += "$('\#no_internet_message').hide();"
						header_url = "https://api.github.com/repos/IGD-Labs/Groundhog/git/refs/heads/master"
						url = JSON.parse(Net::HTTP.get(URI(header_url)))["object"]["url"]
						data = JSON.parse(Net::HTTP.get(URI(url)))
						
						author = data["author"]["name"];
						email = data["author"]["email"];
						message = data["message"];
						update_date = Time.parse(data["author"]["date"]);

						warn "DATE"
						warn date

						warn "UPDATE"
						warn update_date

						days_before = (update_date - date).to_i						
						if days_before >= 1 then
							script += "$('\#no_update_message').hide();$('\#update_info').show();$('\#update_date').text('#{update_date.to_s}');$('\#update_author').text('#{author}');$('\#update_comments').text('#{message}');"
						else
							script += "$('\#no_update_message').show();$('\#update_info').hide();"
						end
					else
						script += "$('\#no_internet_message').show();$('\#no_update_message').hide();$('\#update_info').hide();"
					end
					warn script
					web_dialog.execute_script(script);
				end

				wd.add_action_callback("on_load") do |web_dialog,msg|
					script=""
					@@default_config.each do |field|
						id = field[0].downcase
						script += Utilities.set_element_value(id,@@config,field[1])						
					end				
					date = Time.parse File.readlines("#{IGD::Groundhog::OS.main_groundhog_path}/built").shift.strip		
					script += "$('\#version').text('#{Sketchup.extensions["Groundhog"].version.to_s}');"
					script += "$('\#date').text('#{date.to_s}');"
					script += "$('\#no_update_message').hide();"
					script += "$('\#update_info').hide();"
					script += "$('\#no_internet_message').hide();"			
					
										
					web_dialog.execute_script(script);
				end

				wd.set_on_close{
					@@default_config.each do |field|
						id = field[0].downcase
						@@config[field[0]] = wd.get_element_value(id).strip
					end
					self.write_config_file
				}

				return wd
			end



		end
	end
end
