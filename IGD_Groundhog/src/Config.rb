module IGD
	module Groundhog
		module Config
		
			# Gets the path where the Radiance programs are installed... must be configured by the user.
			# @author German Molina
			# @return path[Void] The radiance bin path
			def self.get_radiance_path
				return "/Applications/Radiance/ray/bin/"
			end		

			def self.rvu_options
				return "-ab 2"
			end

			def self.rtrace_options
				return "-ab 4 -ad 128 -aa 0.2"
			end

			def self.rcontrib_options
				return "-ab 2"
			end
				
			def self.n_threads
				return "4"
			end		
		
		end
	end
end