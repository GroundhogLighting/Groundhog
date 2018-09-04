module GH
	module Groundhog
		# MAIN
		# Groundhog_main.RB

		#Check SU version.
		version_required = 16
		actual_version = Sketchup.version_number

		if (actual_version < version_required)
			UI.messagebox("Groundhog is being developed and tested using Sketchup 20" + version_required.to_i.to_s +
			". Since it seems that you are using an older version, some features might not work correctly."+
			"\n\n You can upgrade SketchUp going to "+
			"www.SketchUp.com")
		end

        #################################
		require 'json'
		require 'fileutils'
		require 'Open3'
		
		Sketchup::require 'GH_Groundhog/src/Debug'
        Sketchup::require 'GH_Groundhog/src/Error'
        Sketchup::require 'GH_Groundhog/src/OS'
		Sketchup::require 'GH_Groundhog/src/Constants'
        Sketchup::require 'GH_Groundhog/src/Version'
        Sketchup::require 'GH_Groundhog/src/Utilities'
        Sketchup::require 'GH_Groundhog/src/Labeler'
		Sketchup::require 'GH_Groundhog/src/Weather'
		Sketchup::require 'GH_Groundhog/src/DesignAssistant'
		Sketchup::require 'GH_Groundhog/src/Observers/Workplanes'
		Sketchup::require 'GH_Groundhog/src/Results'
		Sketchup::require 'GH_Groundhog/src/Report'
		Sketchup::require 'GH_Groundhog/src/Photosensors'
		Sketchup::require 'GH_Groundhog/src/Observers/Photosensors'
		Sketchup::require 'GH_Groundhog/src/LoadHandler'
		

		#########################################

        #############################
        # CHECK GROUNDHOG VERSION
        #############################
        Version.check_version_compatibility()

		# SET AS DEBUG, IF NEEDED
		#########################

		if GH_DEBUG then
			SKETCHUP_CONSOLE.show
			warn " >>> Setting Debug mode on from Groundhog"
			Sketchup.debug_mode = GH_DEBUG
		end

        
		#############################
        # INITIALIZE GROUNDHOG MODEL
        #############################
        model = Sketchup.active_model
        
        #############################
        # ADD REQUIRED PROGRAMS TO PATH
        #############################
        
		##Add Executabls to Path as well as RAYPATH and EMPATH
		OS.setup_executables
		#CHMOD for avoiding permission issues
		Dir["#{GH::Groundhog::OS.executables_path}/*"].each{|bin|
			#next if bin.split("/").pop.include? "."
			FileUtils.chmod(755,bin)
		}

		#######################
		# ADD CONTEXT MENUS
		#######################
	
		UI.add_context_menu_handler do |context_menu|
			faces=Utilities.get_faces(model.selection)
			components = Utilities.get_components(model.selection)
			groups = Utilities.get_groups(model.selection)
			nameables = Utilities.get_nameables(model.selection)

			if nameables.length > 0 then
				context_menu.add_item("Assign Name (GH)") {
					begin
						op_name = "Assign name"
						model.start_operation(op_name,true)
						name=Utilities.get_name_from_user
                        if name then
                            Labeler.set_name(nameables,name)
                            model.commit_operation
                        else
                            model.abort_operation 
                        end
					rescue Exception => ex
						model.abort_operation
						Error.inform_exception(ex)
					end
				}
			end

			if components.length == 1 then
				context_menu.add_item("Label as Luminaire (GH)") {
					begin
						op_name = "Link IES file"
						model.start_operation(op_name,true)
						comp = components[0].definition
						Labeler.to_luminaire(comp)
						model.commit_operation
					rescue Exception => ex
						model.abort_operation
						Error.inform_exception(ex)
					end
				}
			end

			if groups.length == 1 then
				if Labeler.solved_workplane?(groups[0]) then
					context_menu.add_item("Export results to CSV (GH)") {
						Report.report_csv(groups[0])
					}
				end
			end

            

			if faces.length > 0 then
				context_menu.add_item("Label as Illum (GH)") {
					begin
						op_name = "Label as Illum"
						model.start_operation( op_name ,true)

						Labeler.to_illum(faces)

						model.commit_operation
					rescue Exception => ex
						model.abort_operation
						Error.inform_exception(ex)
					end
				}


				context_menu.add_item("Label as Workplane (GH)") {
					begin
						op_name = "Label as Workplane"
						model.start_operation( op_name,true )

						Labeler.to_workplane(faces)

						model.commit_operation
					rescue Exception => ex
						model.abort_operation
						Error.inform_exception(ex)
					end
				}

				context_menu.add_item("Label as Window (GH)") {
					begin
						op_name = "Label as Window"
						model.start_operation( op_name ,true)

						Labeler.to_window(faces)

						model.commit_operation
					rescue Exception => ex
						model.abort_operation
						Error.inform_exception(ex)
					end
				}

				context_menu.add_item("Remove Labels (GH)") {
					begin
						op_name = "Remove Labels"
						model.start_operation( op_name, true)

						Labeler.to_nothing(faces)

						model.commit_operation
					rescue Exception => ex
						model.abort_operation
						Error.inform_exception(ex)
					end
                }
                
				wins=Utilities.get_windows(faces)
                                

			end
		end





		
		
		
		#######################
		### MENUS
		#######################
		
		### GROUNDHOG MENU
		
		extensions_menu = UI.menu "Plugins"
		groundhog_menu=extensions_menu.add_submenu("Groundhog")
		
		
		
		
		
		@design_assistant = DesignAssistant.get
		def self.design_assistant
			@design_assistant
		end
		
		groundhog_menu.add_item("Open Design Assistant"){
			@design_assistant.show			
		}
=begin

		@online_resources = OnlineResources.get
		def self.online_resources
			@online_resources
		end

		groundhog_menu.add_item("Online resources"){
			if Sketchup.version.to_i < 17 then
				UI.messagebox "Sorry... you need to use SketchUp 2017 or older for using these features!"	
			else
				if Sketchup.is_online then
					@online_resources.show
				else
					UI.messagebox "Sorry... you have to be connected to the internet for using this feature"
				end
			end
		}
=end

		groundhog_menu.add_item("Import Emp results"){
			path=Utilities.get_current_path #it returns false if not successful
			path="c:/" if not path
			path=UI.openpanel("Open results file",path,"JSON files|*.json|||")						
			Results.import_results(path) if path
		}
		

		### Show/Hide
		gh_view_menu=groundhog_menu.add_submenu("Show / Hide")

		gh_view_menu.add_item("Illums"){
			Utilities.hide_show_specific(ILLUM)
		}
		gh_view_menu.add_item("Workplanes"){
			Utilities.hide_show_specific(WORKPLANE)
		}
		gh_view_menu.add_item("Solved Workplanes"){
			Utilities.hide_show_specific(SOLVED_WORKPLANE)
		}

=begin

		### EXPORT
		groundhog_menu.add_item("Export Radiance model") {

			path=Exporter.getpath #it returns false if not successful
			path="" if not path

			path_to_save = UI.savepanel("Export model for radiance simulations", path, "RadianceModel")

			if path_to_save then
				OS.mkdir(path_to_save)
				Exporter.export(path_to_save)
			end
		}


		### PREFERENCES MENU

		@preferences_dialog = Config.get
		groundhog_menu.add_item("Preferences") {
				@preferences_dialog.show
		}

		### EXAMPLES MENU
		gh_examples_menu=groundhog_menu.add_submenu("Example files")
		examples = Dir["#{OS.examples_groundhog_path}/*.skp"]
		examples.each{|file|
			example = file.split("/").pop.gsub(".skp","").tr("_"," ")
			gh_examples_menu.add_item(example) {
				path = file
				Sketchup.open_file path
			}
		}

=end
		### HELP MENU

		groundhog_menu.add_item("Online documentation"){
			UI.openURL("http://groundhogproject.gitbooks.io/groundhog-bible/content/")
		}


		# Add the About.
		groundhog_menu.add_item("About Groundhog"){

			str="Groundhog version "+Sketchup.extensions["Groundhog"].version.to_s+"."

			str+="

The Radiance binaries you are using are a courtesy of the U.S. National Renewable Energy Laboratory (www.nrel.gov)"
			str+="

Groundhog was created and it is mainly developed by "+Sketchup.extensions["Groundhog"].creator+", currently working at IGD. Copyrights are held by "+Sketchup.extensions["Groundhog"].copyright
			str+="

Groundhog is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Go to GNU's website for more information about this license."

			UI.messagebox str
		}




		#########################################
		# LOAD CONFIG FILE
		#########################################
	#	if File.exists? Config.config_path then #if a configuration file was once created
	#		Config.load_config
		#end


	end #end module
end
