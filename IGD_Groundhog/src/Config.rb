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
				"PROJECT_NAME" => nil,
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


			# Returns the web dialog that controls the options.
			#
			# @author German Molina
			# @return [SketchUp::UI::WebDialog] the Configuration web dialog			
			def self.get
				wd = UI::WebDialog.new("Preferences", false, "Preferences",595, 490, 100, 100, true )
				wd.set_file("#{OS.main_groundhog_path}/src/html/preferences.html" )

				wd.add_action_callback("on_load") do |web_dialog,msg|
					script=""
					@@default_config.each do |field|
						id = field[0].downcase
						script += Utilities.set_element_value(id,@@config,field[1])
					end					
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
