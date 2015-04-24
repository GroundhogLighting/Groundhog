module IGD
	module Groundhog
		# MAIN
		# Groundhog.RB

		#Check SU version.
		version_required = 15
		actual_version = Sketchup.version_number

		if (actual_version < version_required) 
		  UI.messagebox("Groundhog is being developed and tested using Sketchup 20" + version_required.to_i.to_s +
						". Since it seems that you are using an older version, some features might not work correctly for you."+
						"\n\n You can upgrade SketchUp going to "+
						"www.SketchUp.com")

		end

		#################################

		Sketchup::require 'IGD_Groundhog/Utilities'
		Sketchup::require 'IGD_Groundhog/Labeler'
		Sketchup::require 'IGD_Groundhog/OS'
		Sketchup::require 'IGD_Groundhog/Tools/MkWindow'
		Sketchup::require 'IGD_Groundhog/Exporter'
		Sketchup::require 'IGD_Groundhog/Results'

		#########################################
		model=Sketchup.active_model
		selection=model.selection
		entities=model.entities

	

		#######################
		### CONTEXT MENUS
		#######################

		UI.add_context_menu_handler do |context_menu|
			context_menu.add_separator
		end

		UI.add_context_menu_handler do |context_menu|
		   faces=Utilities.get_faces(Sketchup.active_model.selection)
			if faces.length>=1 then
				context_menu.add_item("Make Window") { 
					MkWindow.make_window(faces)
				}
				context_menu.add_item("Label as Illum") { 
					begin
						op_name = "Label as illum"
						model.start_operation( op_name ,true)
		  
						Labeler.to_illum(faces)
			
						model.commit_operation
					rescue => e
						model.abort_operation
						OS.failed_operation_message(op_name)
					end				
			   }
				horizontal=Utilities.get_horizontal_faces(faces)
				if horizontal.length >=1 then
				   context_menu.add_item("Label as workplane") { 
							begin
								op_name = "Label as workplane"
								model.start_operation( op_name,true )
		  
								Labeler.to_workplane(faces)
			
								model.commit_operation
							rescue => e
								model.abort_operation
								OS.failed_operation_message(op_name)
							end				
				   }
				end
			   context_menu.add_item("Label as Window") { 
					begin
						op_name = "Label as window"
						model.start_operation( op_name ,true)
		  
						Labeler.to_window(faces)
			
						model.commit_operation
					rescue => e
						model.abort_operation
						OS.failed_operation_message(op_name)
					end			
			   }

				context_menu.add_item("Remove Labels") { 
					begin
						op_name = "Remove labels"
						model.start_operation( op_name, true)
		  
						Labeler.to_nothing(faces)
			
						model.commit_operation
					rescue => e
						model.abort_operation
						OS.failed_operation_message(op_name)
					end
			   }
			   wins=Utilities.get_windows(faces)
				if wins.length>1 then
				   context_menu.add_item("Group windows") { 
						begin
							op_name = "Group windows"
							model.start_operation(op_name,true)
						
							prompts=["Name of the window group"]
							defaults=[]
							sys=UI.inputbox prompts, defaults, "Name of the window group"
							model.abort_operation if not sys
							Utilities.group_windows(Sketchup.active_model.selection, sys[0])
			
							model.commit_operation
						rescue => e
							model.abort_operation
							OS.failed_operation_message(op_name)
						end
				   }
				end
			   context_menu.add_item("Assign name") { 
					begin
						op_name = "Assign name"
						model.start_operation(op_name,true)
						name=Utilities.get_name
						model.abort_operation if not name
						Labeler.set_name(Sketchup.active_model.selection,name)
			
						model.commit_operation
					rescue => e
						model.abort_operation
						OS.failed_operation_message(op_name)
					end
			   }

			end
		end






 


		#######################
		### MENUS
		#######################

		### GROUNDHOG MENU

		extensions_menu = UI.menu "Plugins"
		groundhog_menu=extensions_menu.add_submenu("Groundhog")

			#Add the Show Toolbar
			groundhog_menu.add_item("Show Groundhog Toolbar") {
				gh_Toolbar.show
			}


			### TOOLS SUBMENU

			GH_tools_menu=groundhog_menu.add_submenu("Tools")

				GH_tools_menu.add_item("Make Window"){
					Sketchup.active_model.select_tool MkWindow.new
				}




			### RESULTS SUBMENU

			GH_results_menu=groundhog_menu.add_submenu("Results")

				GH_results_menu.add_item("Import results"){
					Results.import_results
				}
		
				GH_results_menu.add_item("Scale handler"){
					s=OS.slash
			
					wd=UI::WebDialog.new( 
						"Scale handler", false, "", 
						180, 380, 100, 100, false )

					wd.set_file( OS.main_groundhog_path+"html"+s+"scale.html" )
			
					wd.add_action_callback("update_scale") do |web_dialog,msg|
						values=msg.split('/')
				
						min=values[0].to_f
						max=values[1].to_f
				
						#check if there is any auto
						if(min<0 or max<0) then
							min_max=Results.get_min_max_from_model
							min=min_max[0] if min<0
							max=min_max[1] if max<0
						end

				
						Results.update_pixel_colors(min,max)
				
						web_dialog.execute_script("document.getElementById('min').value="+min.to_s+";""document.getElementById('max').value="+max.to_s+";");
					end
			
					wd.show()

				}




			### VIEW
			GH_view_menu=groundhog_menu.add_submenu("View")

				GH_view_menu.add_item("Show/Hide illums"){
					Utilities.hide_show_specific("illum")	
				}
				GH_view_menu.add_item("Show/Hide Workplanes"){
					Utilities.hide_show_specific("workplane")	
				}
				GH_view_menu.add_item("Show/Hide window groups"){
					Sketchup.active_model.select_tool GH_Render.new
				}





			### EXPORT
			groundhog_menu.add_item("Export to Radiance") {
				Exporter.export
			}

	
	
	
	
	
			### HELP MENU

			GH_help_menu=groundhog_menu.add_submenu("Help")
				GH_help_menu.add_item("Full Groundhog documentation") {
					s=OS.slash	
					wd=UI::WebDialog.new( 
						"Full doc", true, "", 
						700, 700, 100, 100, true )
					wd.set_file( OS.main_groundhog_path+"doc"+s+"doc_index.html" )			
					wd.show()
				}
	
				## Tutorials
				GH_tutorials_menu=GH_help_menu.add_submenu("Tutorials")
					GH_tutorials_menu.add_item("Getting Started") {
						s=OS.slash	
						wd=UI::WebDialog.new( 
							"Tutorials", true, "", 
							700, 700, 100, 100, true )
						wd.set_file( OS.main_groundhog_path+"doc"+s+"file.GettingStarted.html" )			
						wd.show()	
					}
					GH_tutorials_menu.add_item("Adding windows") {
						s=OS.slash	
						wd=UI::WebDialog.new( 
							"Tutorials", true, "", 
							700, 700, 100, 100, true )
						wd.set_file( OS.main_groundhog_path+"doc"+s+"file.MakeWindow.html" )			
						wd.show()		
					}
					GH_tutorials_menu.add_item("Adding workplanes") {
						s=OS.slash	
						wd=UI::WebDialog.new( 
							"Tutorials", true, "", 
							700, 700, 100, 100, true )
						wd.set_file( OS.main_groundhog_path+"doc"+s+"file.MakeWorkplane.html" )			
						wd.show()	
					}
					GH_tutorials_menu.add_item("Adding illums") {
						s=OS.slash	
						wd=UI::WebDialog.new( 
							"Tutorials", true, "", 
							700, 700, 100, 100, true )
						wd.set_file( OS.main_groundhog_path+"doc"+s+"file.MakeIllum.html" )			
						wd.show()	
					}
					GH_tutorials_menu.add_item("Exporting views") {
						s=OS.slash	
						wd=UI::WebDialog.new( 
							"Tutorials", true, "", 
							700, 700, 100, 100, true )
						wd.set_file( OS.main_groundhog_path+"doc"+s+"file.Views.html" )			
						wd.show()		
					}
					GH_tutorials_menu.add_item("Visualizing results") {
						s=OS.slash	
						wd=UI::WebDialog.new( 
							"Tutorials", true, "", 
							700, 700, 100, 100, true )
						wd.set_file( OS.main_groundhog_path+"doc"+s+"file.ImportResults.html" )			
						wd.show()		
					}

			# Add the About.
			groundhog_menu.add_item("About Groundhog"){
				UI.messagebox "Groundhog version "+Sketchup.extensions["Groundhog"].version.to_s+"\n\nCreator:\n"+Sketchup.extensions["Groundhog"].creator+"\n\nCopyright:\n"+Sketchup.extensions["Groundhog"].copyright
			}

	end #end module
end