module IGD
	module Groundhog
		# MAIN
		# Groundhog_main.RB

		#Check SU version.
		version_required = 15
		actual_version = Sketchup.version_number

		if (actual_version < version_required)
			UI.messagebox("Groundhog is being developed and tested using Sketchup 20" + version_required.to_i.to_s +
			". Since it seems that you are using an older version, some features might not work correctly."+
			"\n\n You can upgrade SketchUp going to "+
			"www.SketchUp.com")
		end

		#################################

		Sketchup::require 'IGD_Groundhog/src/Error'
		Sketchup::require 'IGD_Groundhog/src/Observers'
		Sketchup::require 'IGD_Groundhog/src/Triangle'
		Sketchup::require 'IGD_Groundhog/src/Utilities'
		Sketchup::require 'IGD_Groundhog/src/Config'
		Sketchup::require 'IGD_Groundhog/src/Labeler'
		Sketchup::require 'IGD_Groundhog/src/OS'
		Sketchup::require 'IGD_Groundhog/src/Exporter'
		Sketchup::require 'IGD_Groundhog/src/Results'
		Sketchup::require 'IGD_Groundhog/src/Materials'
		Sketchup::require 'IGD_Groundhog/src/LoadHandler'
		Sketchup::require 'IGD_Groundhog/src/Color'
		Sketchup::require 'IGD_Groundhog/src/Luminaires'
		Sketchup::require 'IGD_Groundhog/src/Tdd'
		Sketchup::require 'IGD_Groundhog/src/Weather'
		Sketchup::require 'IGD_Groundhog/src/DesignAssistant'
		Sketchup::require 'IGD_Groundhog/src/SimulationManager'
		Sketchup::require 'IGD_Groundhog/src/Report'
		Sketchup::require 'IGD_Groundhog/src/Objectives'
		Sketchup::require 'IGD_Groundhog/src/Metrics'


		Sketchup::require 'IGD_Groundhog/src/Scripts/AnnualIlluminance'
		Sketchup::require 'IGD_Groundhog/src/Scripts/CalcDC'
		Sketchup::require 'IGD_Groundhog/src/Scripts/InstantIlluminance'
		Sketchup::require 'IGD_Groundhog/src/Scripts/Sky'
		Sketchup::require 'IGD_Groundhog/src/Scripts/SkyContribution'
		Sketchup::require 'IGD_Groundhog/src/Scripts/TDDContribution'
		Sketchup::require 'IGD_Groundhog/src/Scripts/TDDDaylight'
		Sketchup::require 'IGD_Groundhog/src/Scripts/TDDPipe'
		Sketchup::require 'IGD_Groundhog/src/Scripts/TDDView'
		Sketchup::require 'IGD_Groundhog/src/Scripts/Elux'



		require 'json'
		require 'Open3'
		require 'fileutils'
		require 'date'
		require 'Net/Http' #used only for checking updates

		#########################################
		model=Sketchup.active_model


		current_model_version = model.get_attribute("Groundhog","version")
		current_groundhog_version = Sketchup.extensions["Groundhog"].version.to_s
		if current_model_version == nil then
			model.set_attribute("Groundhog","version",current_groundhog_version)
			any_objective = false
			wps =Utilities.get_workplanes(Sketchup.active_model.entities)
			wps.each {|wp|
				if Labeler.get_value(wp) != nil then
					any_objective = true
					break
				end
			}
			if any_objective then
				result = UI.messagebox('It seems that you worked on this project using an earlier version of Groundhog... would you like to try to update it?', MB_YESNO)
				if result == IDYES
					begin
						objs = Hash.new
						wps.each{|wp|
							val = JSON.parse(Labeler.get_value(wp))
							wp_value = []
							val.each{|ob|
								objs[ob["name"]]=ob
								wp_value << ob["name"]
							}
							Labeler.set_value(wp,wp_value.to_json)
						}
						Sketchup.active_model.set_attribute("Groundhog","objectives",objs.to_json)
					rescue
						UI.messagebox("There was an error in this transformation... sorry. Please re-edit all objectives in your model.")
					end
				end
			end
		else
			# Do something about compatibility!
			compare = Utilities.compare_versions(current_model_version,current_groundhog_version)
			if compare == 0 then #same version... all OK

			elsif compare < 0 then #model version is newer than GH version

			else #model version is older than GH version.
				#update model to make them compatible?

			end
		end

		model.set_attribute("Groundhog","objectives",Hash.new.to_json) if model.get_attribute("Groundhog","objectives") == nil #Objectives will be stored here.
		model.set_attribute("Groundhog","workplanes",Hash.new.to_json) if model.get_attribute("Groundhog","workplanes") == nil #Workplane's objectives will be stored here.


		#Add Radiance to Path as well as RAYPATH
		OS.setup_radiance
		#CHMOD for avoiding permission issues
		Dir["#{IGD::Groundhog::OS.radiance_path}/*"].each{|bin|
			next if bin.split("/").pop.include? "."
			FileUtils.chmod(755,bin)
		}

		#######################
		### CONTEXT MENUS
		#######################

		UI.add_context_menu_handler do |context_menu|
			context_menu.add_separator
		end

		UI.add_context_menu_handler do |context_menu|
			faces=Utilities.get_faces(Sketchup.active_model.selection)
			namables = Utilities.get_namables(Sketchup.active_model.selection)
			components = Utilities.get_components(Sketchup.active_model.selection)
			groups = Utilities.get_groups(Sketchup.active_model.selection)

			if namables.length >= 1 then
				context_menu.add_item("Assign Name (GH)") {
					begin
						op_name = "Assign name"
						model.start_operation(op_name,true)
						name=Utilities.get_name
						model.abort_operation if not name
						Labeler.set_name(Sketchup.active_model.selection,name)
						model.commit_operation
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

			if groups.length >= 1 then
				context_menu.add_item("Label as Tubular Daylight Device (GH)") {
					Labeler.to_tdd(groups)
				}
			end
			if components.length >= 1 then
				context_menu.add_item("Label as Tubular Daylight Device (GH)") {
					Labeler.to_tdd(components)
				}
			end

			if faces.length == 1 then
				if Labeler.tdd?(faces[0].parent) then
					context_menu.add_item("Label as TDD's Dome (GH)"){
						Labeler.to_tdd_top(faces[0])
					}
					context_menu.add_item("Label as TDD's Diffuser (GH)"){
						Labeler.to_tdd_bottom(faces[0])
					}
				end
			end

			if faces.length>=1 then
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
				if wins.length>1 then
					context_menu.add_item("Group windows (GH)") {
						begin
							op_name = "Group windows"
							model.start_operation(op_name,true)

							prompts=["Name of the window group"]
							defaults=[]
							sys=UI.inputbox prompts, defaults, "Name of the window group"
							model.abort_operation if not sys
							Utilities.group_windows(Sketchup.active_model.selection, sys[0])

							model.commit_operation
						rescue Exception => ex
							model.abort_operation
							Error.inform_exception(ex)
						end
					}
				end

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
		groundhog_menu.add_item("Import results"){
			path=Exporter.getpath #it returns false if not successful
			path="c:/" if not path
			path=UI.openpanel("Open results file",path)
			Results.import_results(path,false) if path
		}


		### INSERT SUBMENU

		gh_insert_menu=groundhog_menu.add_submenu("Insert")

		gh_insert_menu.add_item("Illuminance Sensor"){
			Loader.load_illuminance_sensor
		}
=end

		### Show/Hide
		gh_view_menu=groundhog_menu.add_submenu("Show / Hide")

		gh_view_menu.add_item("Illums"){
			Utilities.hide_show_specific("illum")
		}
		gh_view_menu.add_item("Workplanes"){
			Utilities.hide_show_specific("workplane")
		}
		gh_view_menu.add_item("Solved Workplanes"){
			Utilities.hide_show_specific("solved_workplane")
		}


		### EXPORT
		groundhog_menu.add_item("Export to Radiance") {

			path=Exporter.getpath #it returns false if not successful
			path="" if not path

			path_to_save = UI.savepanel("Export model for radiance simulations", path, "Radiance Model")

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
				UI.messagebox("Unable to open '#{example}' Example File.") if not Sketchup.open_file path
			}
		}


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
		if File.exists? Config.config_path then #if a configuration file was once created
			Config.load_config
		end


	end #end module
end
