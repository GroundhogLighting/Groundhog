module IGD
	module Groundhog
		module Config
		
			@@rad_config=Hash.new() 
			
			def self.get_rad_config
				@@rad_config
			end
			
			# Gets the path where the Radiance programs are installed... must be configured by the user.
			# @author German Molina
			# @return path [String] The radiance bin path
			def self.radiance_path
				@@rad_config["RADIANCE_PATH"]
			end		

			# Gets the preconfigured RVU options for previsualization
			# @author German Molina
			# @return options[String] The options
			def self.rvu_options
				@@rad_config["RVU"]
			end

			# Gets the preconfigured RTRACE options for calculations
			# @author German Molina
			# @return options[String] The options
			def self.rtrace_options
				@@rad_config["RTRACE"]
			end

			# Gets the preconfigured RCONTRIB options for calculations
			# @author German Molina
			# @return options[String] The options
			def self.rcontrib_options
				@@rad_config["RCONTRIB"]
			end

			# Gets the number of threads to be used by Radiance programs.
			#	Windows always returns 1.
			# @author German Molina
			# @return n_threads [String] The number of threads
			def self.n_threads
				return "1" if OS.getsystem == "Win"
				return @@rad_config["THREADS"]				
			end	
			
			# Gets the number of threads to be used by Radiance programs.
			#	Windows always returns 1.
			# @author German Molina
			# @return n_threads [String] The number of threads
			def self.sensor_spacing
				return @@rad_config["SENSOR_SPACING"] if @@rad_config["SENSOR_SPACING"]!= nil
				prompts=["Workplane Sensor Spacing (m)"]
				defaults=[0.5]
				sys=UI.inputbox prompts, defaults, "Spacing of the sensors on workplanes?"
				return sys[0]
			end	
			
			
			# Loads the configuration file into the configuration hash.
			# If the file does not exist, it ask you to fill it.
			# @author German Molina
			# @return void
			def self.load_rad_config
				s=OS.slash
				path="#{OS.main_groundhog_path}rad.cfg"
				UI.messagebox("It seems that you have not configured Groundhog yet.\nPlease do it.") if not File.exist?(path)
				if not File.exist?(path) then
					return false if not self.set_rad_config 
				end
				
				@@rad_config=JSON.parse(File.open(path).read)
				return true
			end

			# Asks the user for the information to put in the config file.
			# After that, it writes it down.
			# @author German Molina
			# @return void			
			def self.set_rad_config
				
				config_path="#{OS.main_groundhog_path}rad.cfg"
					
				prompts = ["Radiance path","Threads", "RVU", "RCONTRIB", "RTRACE", "Sensor spacing"]
				
				defaults=[]
				old_path=false
				if File.exists?(config_path) then
					d=JSON.parse(File.open(config_path).read)
					defaults << d["RADIANCE_PATH"].to_s
					old_path=d["RADIANCE_PATH"]
					defaults << d["THREADS"].to_s
					defaults << d["RVU"]
					defaults << d["RCONTRIB"]
					defaults << d["RTRACE"]
					defaults << d["SENSOR_SPACING"].to_s
				else	
					defaults = ["","1", "-ab 2 -ad 128","-ab 2 -ad 128","-ab 2 -ad 128", "0.5"]
				end
				
				input=[]
				while true do #this will bother the users until it inserts valid inputs OR desists.
					input = UI.inputbox(prompts, defaults, "Please configure the Radiance parameters")
					return false if not input #if the user press "cancel"
					
					#now we test the inputs
					
					#path
					UI.messagebox("Please insert a non-empty path.") if input[0]=="" 
					next if input[0]=="" 
					UI.messagebox("Directory not found. Please insert another one.") if not File.directory?(input[0])
					defaults[0]=input[0] #avoids erasing the well-written stuff
					next if not File.directory?(input[0])
					
					#threads
					input[1]=input[1].to_i
					UI.messagebox("The number of threads must be an integer equal or greater than 1") if input[1] < 1
					defaults[1]=input[1]
					next if input[1] < 1
					
					#spacing
					input[5]=input[5].to_f
					UI.messagebox("The sensor spacing must be a number greater than 0.") if input[5] <=0
					defaults[5]=input[5]
					next if input[5] <=0
					
					break #if it passed all the tests.
				end
				
				#update the rad_config hash
				@@rad_config["RADIANCE_PATH"]=input[0]
				@@rad_config["THREADS"]=input[1].to_i
				@@rad_config["RVU"]=input[2]				
				@@rad_config["RCONTRIB"]=input[3]
				@@rad_config["RTRACE"]=input[4]
				@@rad_config["SENSOR_SPACING"]=input[5].to_f
				
				#write the rad file
				File.open(config_path,'w+'){ |f| 
					f.write(@@rad_config.to_json)
				}		
				
				#update the path
				if not old_path then
					ENV["PATH"]=Config.radiance_path+":" << ENV["PATH"]
				else
					ENV["PATH"]=ENV["PATH"].split(old_path).join(Config.radiance_path) #erase the old one and replace it
				end			
				
				return true								
			end
						
		end
	end
end