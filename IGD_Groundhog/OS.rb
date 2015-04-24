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
				sys=self.getsystem
				if sys=="MAC" then
					system("mkdir '"+path+"'")
				elsif sys=="WIN" then
					system('mkdir "'+path+'"')
				else
					return false
				end
			end

			# Gets the path where the plugin is installed
			# @author German Molina
			# @param path [String] The path with the directory to create
			# @return path[Void] The main groundhog path
			def self.main_groundhog_path
		
				files = Sketchup.find_support_file "IGD_Groundhog.rb" ,"Plugins"
				s=self.slash
				array=files.split("/")
				array=array.first(array.length-1)
				return array.join(s)+s+"IGD_Groundhog"+s
	
			end		

			# Sends an error message saying that an operation failed
			# @author German Molina
			# @param operation name [String] The name of the failed operation
			def self.failed_operation_message(op_name)
				UI.messagebox("There was an error while performing #{op_name} operation.\n\nPlease contact #{Groundhog.creator} to tell us what happened.\n\nTHANKS!")
			end		
	

		end
	end #end module
end