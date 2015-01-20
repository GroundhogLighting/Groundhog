# This file contains the system related topics related to the different Operating Systems, and system calls
class GH_OS

	# Identifies the GH_OS. Returns "MAC", "WIN" or "OTHER" when used.
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
			return "/" #it is assumed that OTHER GH_OS will work as MAC...???
		end			
	end

	# Returns the path where the radiance materials should be stored.
	# @author German Molina
	# @param [Void]
	# @return [String] The corresponding path
	# @note It would be ideal to allow customizing this path, so the user can choose it.
	def self.rad_material_path
		sys=self.getsystem
		if sys=="MAC" 
			"/Applications/Groundhog/RadianceMaterials/" # Example of a directory in Mac
		elsif sys=="WIN"
			"C:\\Program Files (x86)\\Groundhog\\RadianceMaterials\\" #Example of a directory in Windows
		else
			UI.messagebox "Sorry, unsupported Operative System"
		end
	end

	# Returns the path where the radiance components should be stored.
	# @author German Molina
	# @param [Void]
	# @return [String] The corresponding path
	# @note This material is not yet in use, since there is no support for components in Groundhog yet.
	def self.rad_component_path
		"/Applications/Otros/RadianceResources/Furniture/"
	end

end