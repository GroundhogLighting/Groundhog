module GH
	module Groundhog

		# This module contains the system related topics related to the different Operating Systems, and system calls
		module OS

			# Identifies the OS. Returns "MAC", "WIN" or "OTHER" when used.
			#
			# @author German Molina
			# @return [String] Operating System. "WIN","MAC" or "OTHER"
			def self.get_os

				#mac = ( Object::RUBY_PLATFORM =~ /darwin/i ? true : false )
				#win = ( (Object::RUBY_PLATFORM =~ /mswin/i || Object::RUBY_PLATFORM =~ /mingw/i) ? true : false )

				win = Sketchup.platform == :platform_win
  				mac = Sketchup.platform == :platform_osx

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
=begin
			# Gets the path where the Radiance programs are installed.
			# @author German Molina
			# @return [String] The radiance bin path
			def self.radiance_path
				"#{self.main_groundhog_path}/src/Radiance/bin"
			end

			# Gets the path where the Radiance library is installed
			# @author German Molina
			# @return [String] The radiance bin path
			def self.raypath
				"#{OS.main_groundhog_path}/src/Radiance/lib"
			end

			# Adds the Radiance Path and the Raypath to the environmental variables.
			# @author German Molina
			def self.setup_radiance
				# ADD RADIANCE_PATH
				if self.radiance_path then
					divider = ":"
					divider = ";" if self.getsystem == "WIN"
					ENV["PATH"]=self.radiance_path+divider << ENV["PATH"]
					ENV["RAYPATH"] = "#{self.raypath}"
				else
					UI.messagebox "There was a problem loading Radiance"
				end
			end


			# Creates a directory in the selected path
			# @author German Molina
			# @param path [String] The path with the directory to create
			# @return [Void]
			def self.mkdir(path)
				Dir.mkdir(path) unless File.directory?(path)
			end
=end
			# Gets the path where the plugin is installed
			# @author German Molina
			# @return [String] The main groundhog path
			def self.main_groundhog_path
				files = Sketchup.find_support_file "GH_Groundhog.rb" ,"Plugins"
				array=files.split("/")
				array.pop
				array.push("GH_Groundhog")
				return File.join(array)
			end
=begin
			# Gets the path where the groundhog's support files are stored
			# @author German Molina
			# @return [String] The tmp groundhog path
			def self.support_files_groundhog_path
				dir=self.main_groundhog_path
				array=dir.split("/")
				array.push("Assets")
				array.push("support_files")
				return File.join(array)
			end

			# Gets the path where the Examples are stored
			# @author German Molina
			# @return [Void] The examples groundhog path
			def self.examples_groundhog_path
				dir=self.main_groundhog_path
				array=dir.split("/")
				array.push("Examples")
				return File.join(array)
			end

			# Removes everything from the input path
			# The commands need to be strings.
			# @author German Molina
			# @param path [String] the path to clean
			def self.clear_path(path)
				FileUtils.cd(path) do
					self.clear_actual_path
				end

				return true
			end

			# Removes everything from the actual path
			# The commands need to be strings.
			# @version 0.3
			# @author German Molina
			def self.clear_actual_path
				FileUtils.rm_rf(Dir.glob('./*'), secure: true)
				return true
			end

			# Runs a command, printing the Stoud and Stderr on the console. Returns True if everything went well, and false if it did not.
			# @author German Molina
			# @param cmd [String] The command to execute.
			# @return [Boolean] success
			def self.run_command(cmd)

				exit_status=""
				warn ">> #{cmd}"
				Sketchup.set_status_text cmd ,SB_PROMPT
				Open3.popen3(cmd){ |stdin, stdout, stderr, wait_thr|
					pid = wait_thr.pid # pid of the started process.

					while line = stderr.gets
						warn line
					end

					while line = stdout.gets
						warn line
					end

					exit_status = wait_thr.value.success?
				}
				return exit_status
			end

			# Executes a series of commands in an array. This allows easy scripting within SketchUp.
			# The commands need to be strings.
			# @author German Molina
			# @param script [Array] The script
			# @return [Boolean] success
			def self.execute_script(script)
				return false if not script

				script.each  do |cmd|
					return false if not self.run_command(cmd)
				end
				return true
			end

			# Based on some options, the method returns the oconv command that will
			# gather all the elements needed in the model.
			# @author German Molina
			# @return [String] The correspondingnoconv command
			# @note This program is meant to be called from within the export directory
			def self.oconv_command(options)
				win_string = ""
				win_string = "./Windows/windows.rad" if File.directory? "Windows"
				ret = "oconv ./Materials/materials.mat ./scene.rad #{win_string}"
				UI.messagebox("The sky '#{options[:sky]}' does was not exported... from OS.oconv_command") if options[:sky] and not File.file? "./Skies/#{options[:sky]}.rad"

				ret +=  " ./Skies/#{options[:sky]}.rad" if options[:sky] and File.file? "./Skies/#{options[:sky]}.rad"
				ret += " ./Components/Lights/all.lightsources" if options[:lights_on] and File.file? "./Components/Lights/all.lightsources"

				return ret
			end

=end
		end
	end #end module
end
