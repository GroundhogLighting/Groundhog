module IGD
	module Groundhog
		# This file contains the system related topics related to the different Operating Systems, and system calls
		module OS

			# Identifies the OS. Returns "MAC", "WIN" or "OTHER" when used.
			# From {http://www.sketchup.com/intl/en/developer/docs/faq SketchUp FAQ}
			# Added by German Molina
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


			# Creates a directory in the selected path
			# @author German Molina
			# @param path [String] The path with the directory to create
			# @return [Void]
			def self.mkdir(path)
				Dir.mkdir(path) unless File.directory?(path)
			end

			# Gets the path where the plugin is installed
			# @author German Molina
			# @return [String] The main groundhog path
			def self.main_groundhog_path
				files = Sketchup.find_support_file "IGD_Groundhog.rb" ,"Plugins"
				array=files.split("/")
				array.pop
				array.push("IGD_Groundhog")
				return File.join(array)
			end

			# Gets the path where the groundhog's support files are stored
			# @author German Molina
			# @return [String] The tmp groundhog path
			def self.support_files_groundhog_path
				dir=self.main_groundhog_path
				array=dir.split("/")
				array.push("support_files")
				return File.join(array)
			end

			# Gets the path where a temporal Radiance project will be exported for analysis
			# @author German Molina
			# @return [String] The tmp groundhog path
			def self.tmp_groundhog_path
				dir=self.main_groundhog_path
				array=dir.split("/")
				array.push("tmp")
				return File.join(array)
			end

			# Gets the path where the Examples are stored
			# @author German Molina
			# @return [Void] The tmp groundhog path
			def self.examples_groundhog_path
				dir=self.main_groundhog_path
				array=dir.split("/")
				array.push("Examples")
				return File.join(array)
			end

			# Gets the path where the Add-ons are stored
			# @author German Molina
			# @return [Void] The add-on groundhog path
			def self.addons_groundhog_path
				dir=self.main_groundhog_path
				array=dir.split("/")
				array.push("Addons")
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
				FileUtils.rm_rf(Dir.glob('./*'))
				return true
			end

			# Runs a command, printing the Stoud and Stderr on the console. Returns True if everything went well, and false if it did not.
			# @author German Molina
			# @param cmd [String] The command to execute.
			# @return [Boolean] success
			def self.run_command(cmd)
				UI.messagebox("Either your Radiance configuration is incorrect or inexistent.\n\nPlease reconfigure.") if not Config.radiance_path
				return false if Config.radiance_path == nil

				exit_status=""
				warn ">> #{cmd}"
				Sketchup.set_status_text cmd ,SB_PROMPT
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
			# @return [Boolean] success
			def self.execute_script(script)
				return false if not script

				script.each  do |cmd|
					return false if not self.run_command(cmd)
				end
				return true
			end

			# Receives the name of a program... adds .exe if necessary
			# @author German Molina
			# @param program [String] The name of the program to check
			# @return [String] True if Radiance was installed... if not, it offers to do it, and return false
			def self.program(program)
				sys = self.getsystem
				return program if sys == "MAC"
				return "#{program}.exe" if sys == "WIN"
			end


		end
	end #end module
end
