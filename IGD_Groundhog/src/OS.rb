module IGD
	module Groundhog
		# This file contains the system related topics related to the different Operating Systems, and system calls
		module OS

			# Identifies the OS. Returns "MAC", "WIN" or "OTHER" when used.
			# From {http://www.sketchup.com/intl/en/developer/docs/faq SketchUp FAQ}
			# Added by German Molina  
			# @param [Void]
			# @return [String] Operating System. "WIN","MAC" or "OTHER"
			def self.getsystem
		
				mac = ( Object::RUBY_PLATFORM =~ /darwin/i ? true : false )
				win = ( (Object::RUBY_PLATFORM =~ /mswin/i || Object::RUBY_PLATFORM =~ /mingw/i) ? true : false )
	
				os=""
				if mac # You are running on a Mac computer.
					os="MAC"
				elsif win # You are running on a Windows computer.
					os="WIN"
				else # You are running on another architecture.
					os="OTHER"
				end
				return os
			end

			# Returns the "slash" required for each O.S.
			#
			# Window 7 and Mac use different "slashes". 
			# @author German Molina
			# @param [Void]
			# @return [String] The corresponding Slash ("\\" for WIN and "/" for MAC or OTHER).
			def self.slash
				os=self.getsystem
		
				if os=="WIN"
					return "\\" #This was correct in Windows XP, when tried
				else 
					return "/" #it is assumed that OTHER OS will work as MAC...???
				end			
			end
	
			# Creates a directory in the selected path
			# @author German Molina
			# @param path [String] The path with the directory to create
			# @return [Void]
			def self.mkdir(path)
#				sys=self.getsystem
#				if sys=="MAC" then
#					#system("mkdir '"+path+"'")
#				elsif sys=="WIN" then
#					system('mkdir "'+path+'"')
#				else
#					return false
#				end
				Dir.mkdir(path) unless File.directory?(path)
			end

			# Gets the path where the plugin is installed
			# @author German Molina
			# @return path[Void] The main groundhog path
			def self.main_groundhog_path
		
				files = Sketchup.find_support_file "IGD_Groundhog.rb" ,"Plugins"
				s=self.slash
				array=files.split("/")
				array=array.first(array.length-1)
				return array.join(s)+s+"IGD_Groundhog"+s
	
			end		

			# Gets the path where a temporal Radiance project will be exported for analysis
			# @author German Molina
			# @return path[Void] The tmp groundhog path
			def self.tmp_groundhog_path
		
				files = Sketchup.find_support_file "IGD_Groundhog.rb" ,"Plugins"
				s=self.slash
				array=files.split("/")
				array=array.first(array.length-1)
				return array.join(s)+s+"IGD_Groundhog"+s+"tmp"+s	
			end		

			
			# Sends an error message saying that an operation failed
			# @author German Molina
			# @param operation name [String] The name of the failed operation
			def self.failed_operation_message(op_name)
				UI.messagebox("There was an error while performing #{op_name} operation.\n\nPlease contact #{Groundhog.creator} to tell us what happened.\n\nTHANKS!")
			end		


			# Removes everything from the input path
			# The commands need to be strings.
			# @author German Molina
			# @param void
			def self.clear_path(path)
				dirs=["Workplanes","Materials","Windows","Geometry","Illums","Results","Skies","Views", "Components"]
				files=["octree.oct","scene.rad","scene.rif"]
				
				FileUtils.cd(path) do
					self.clear_actual_path
				end
				
				return true
			end

			# Removes everything from the actual path
			# The commands need to be strings.
			# @author German Molina
			# @param void
			def self.clear_actual_path
				dirs=["Workplanes","Materials","Windows","Geometry","Illums","Results","Skies","Views", "Components"]
				files=["octree.oct","scene.rad","scene.rif"]								
				dirs.each do |dir|
					next if not File.directory?(dir)
					FileUtils.rm_rf(dir)
				end
			
				files.each do |fl|
					File.delete(fl) if File.exists?(fl)					
				end
				
				return true
			end

			# Runs a command, printing the Stoud and Stderr on the console. Returns True if everything went well, and false if it did not.
			# @author German Molina
			# @param cmd [String] The command to execute.
			def self.run_command(cmd)
				UI.messagebox("Either your Radiance configuration is incorrect or inexistent.\n\nPlease reconfigure.") if Config.radiance_path == nil
				return false if Config.radiance_path == nil
				
				exit_status=""
				Open3.popen3(cmd){ |stdin, stdout, stderr, wait_thr|
					pid = wait_thr.pid # pid of the started process.					
					
					while line = stderr.gets
						puts line
					end												

					while line = stdout.gets
						puts line
					end			
					
					exit_status = wait_thr.value.success?
				}				
				return exit_status
			end
			
			# Executes a series of commands in an array. This allows easy scripting within SketchUp.
			# The commands need to be strings.
			# @author German Molina
			# @param script [Array] The script
			def self.execute_script(script)
				script.each  do |cmd|
					return false if not self.run_command(cmd)
				end
				return true
			end

		end
	end #end module
end