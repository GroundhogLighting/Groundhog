# MAIN
# Groundhog.RB

#################################

Sketchup::require 'Groundhog/GH_Utilities'
Sketchup::require 'Groundhog/GH_Labeler'
Sketchup::require 'Groundhog/GH_OS'
Sketchup::require 'Groundhog/Tools/GH_MkWindow'
Sketchup::require 'Groundhog/GH_Exporter'
Sketchup::require 'Groundhog/GH_Results'

#########################################
model=Sketchup.active_model
selection=model.selection
entities=model.entities

#Add the default materials to the model
Sketchup.active_model.materials.add "GH_default_material"
Sketchup.active_model.materials["GH_default_material"].color=[0.7,0.7,0.7]
Sketchup.active_model.materials.add "GH_default_glass"
Sketchup.active_model.materials["GH_default_glass"].color=[0.0,0.0,1.0]
Sketchup.active_model.materials["GH_default_glass"].alpha=0.2	



#######################
### TOOLBAR
#######################


gh_Toolbar=UI::Toolbar.new "Groundhog"


### Make Window
 
mkWindow = UI::Command.new("mkWindow") { 
       Sketchup.active_model.select_tool GH_MkWindow.new
 }
 mkWindow.small_icon = "Icons/mkWindow.png"
 mkWindow.large_icon = "Icons/mkWindow.png"
 mkWindow.tooltip = "Makes a window"
 mkWindow.status_bar_text = "Makes a window"
 mkWindow.menu_text = "Makes a window"

gh_Toolbar = gh_Toolbar.add_item mkWindow 



### Show Toolbar.
gh_Toolbar.show

#######################
### CONTEXT MENUS
#######################

UI.add_context_menu_handler do |context_menu|
	context_menu.add_separator
end

UI.add_context_menu_handler do |context_menu|
   faces=GH_Utilities.get_faces(Sketchup.active_model.selection)
	if faces.length>=1 then
	   context_menu.add_item("Label as Illum") { 
			begin
				op_name = "Label as illum"
				model.start_operation( op_name )
		  
				GH_Labeler.to_illum(faces)
			
				model.commit_operation
			rescue => e
				model.abort_operation
				UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
			end				
	   }
	end
end

UI.add_context_menu_handler do |context_menu|
   faces=GH_Utilities.get_horizontal_faces(Sketchup.active_model.selection)
	if faces.length>=1 then
	   context_menu.add_item("Label as workplane") { 
			begin
				op_name = "Label as workplane"
				model.start_operation( op_name )
		  
				GH_Labeler.to_workplane(faces)
			
				model.commit_operation
			rescue => e
				model.abort_operation
				UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
			end				
	   }
	end
end

UI.add_context_menu_handler do |context_menu|
   faces=GH_Utilities.get_faces(Sketchup.active_model.selection)
	if faces.length>=1 then
	   context_menu.add_item("Label as Window") { 
			begin
				model.start_operation( "Label as window" )
		  
				GH_Labeler.to_window(faces)
			
				model.commit_operation
			rescue => e
				model.abort_operation
				UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
			end			
	   }
	end
end

UI.add_context_menu_handler do |context_menu|
   faces=GH_Utilities.get_faces(Sketchup.active_model.selection)
	if faces.length>=1 then
		context_menu.add_item("Remove Labels") { 
			begin
				model.start_operation( "Remove Labels" )
		  
				GH_Labeler.to_nothing(faces)
			
				model.commit_operation
			rescue => e
				model.abort_operation
				UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
			end
	   }
	end
end


UI.add_context_menu_handler do |context_menu|
   wins=GH_Utilities.get_windows(Sketchup.active_model.selection)
	if wins.length>1 then
	   context_menu.add_item("Group windows") { 
			prompts=["Name of the window group"]
			defaults=[]
			sys=UI.inputbox prompts, defaults, "Spacing of the sensors on workplanes?"
			
			begin
				model.start_operation( "Group Windows" )
			
				GH_Utilities.group_windows(Sketchup.active_model.selection, sys[0])
			
				model.commit_operation
			rescue => e
				model.abort_operation
				UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
			end
	   }
	end
end

UI.add_context_menu_handler do |context_menu|
   faces=GH_Utilities.get_faces(Sketchup.active_model.selection)
	if faces.length>=1 then
	   context_menu.add_item("Assign name") { 
			begin
				model.start_operation( "Assign name" )
		  
				GH_Labeler.set_name(Sketchup.active_model.selection)
			
				model.commit_operation
			rescue => e
				model.abort_operation
				UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
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
			Sketchup.active_model.select_tool GH_MkWindow.new
		}




	### RESULTS SUBMENU

	GH_results_menu=groundhog_menu.add_submenu("Results")

		GH_results_menu.add_item("Import results"){
			GH_Results.import_results
		}
		
		GH_results_menu.add_item("Scale handler"){
			s=GH_OS.slash
			
			wd=UI::WebDialog.new( 
				"Scale handler", false, "", 
				180, 340, 100, 100, false )

			wd.set_file( GH_OS.main_groundhog_path+"html"+s+"scale.html" )
			
			wd.add_action_callback("update_scale") do |web_dialog,msg|
				values=msg.split('/')
				
				min=values[0].to_f
				max=values[1].to_f
				
				#check if there is any auto
				if(min<0 or max<0) then
					min_max=GH_Results.get_min_max_from_model
					min=min_max[0] if min<0
					max=min_max[1] if max<0
				end

				
				GH_Results.update_pixel_colors(min,max)
			end
			
			wd.show()
		}




	### VIEW
	GH_view_menu=groundhog_menu.add_submenu("View")

		GH_view_menu.add_item("Show/Hide illums"){
			GH_Utilities.hide_show_specific("illum")	
		}
		GH_view_menu.add_item("Show/Hide Workplanes"){
			GH_Utilities.hide_show_specific("workplane")	
		}
		GH_view_menu.add_item("Show/Hide window groups"){
			Sketchup.active_model.select_tool GH_Render.new
		}





	### EXPORT
	groundhog_menu.add_item("Export to Radiance") {
		GH_Exporter.export
	}

	
	
	
	
	
	### HELP MENU

	GH_help_menu=groundhog_menu.add_submenu("Help")
		GH_help_menu.add_item("Full Groundhog documentation") {
	
			s=GH_OS.getsystem
			if Sketchup.is_online
				UI.openURL "http://igd-labs.github.io/Groundhog/doc/doc_index.html"
			elsif
				UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
			end
		}
	
		## Tutorials
		GH_tutorials_menu=GH_help_menu.add_submenu("Tutorials")
			GH_tutorials_menu.add_item("Getting Started") {
	
				s=GH_OS.getsystem
				if Sketchup.is_online
					UI.openURL "http://igd-labs.github.io/Groundhog/doc/file.GettingStarted.html"
				elsif
					UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
				end
			}
			GH_tutorials_menu.add_item("Adding windows") {
	
				s=GH_OS.getsystem
				if Sketchup.is_online
					UI.openURL "http://igd-labs.github.io/Groundhog/doc/file.MakeWindow.html"
				elsif
					UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
				end
			}
			GH_tutorials_menu.add_item("Adding workplanes") {
	
				s=GH_OS.getsystem
				if Sketchup.is_online
					UI.openURL "http://igd-labs.github.io/Groundhog/doc/file.MakeWorkplane.html"
				elsif
					UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
				end
			}
			GH_tutorials_menu.add_item("Adding illums") {
	
				s=GH_OS.getsystem
				if Sketchup.is_online
					UI.openURL "http://igd-labs.github.io/Groundhog/doc/file.MakeIllum.html"
				elsif
					UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
				end
			}
			GH_tutorials_menu.add_item("Exporting views") {
	
				s=GH_OS.getsystem
				if Sketchup.is_online
					UI.openURL "http://igd-labs.github.io/Groundhog/doc/file.Views.html"
				elsif
					UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
				end
			}
			GH_tutorials_menu.add_item("Visualizing results") {
	
				s=GH_OS.getsystem
				if Sketchup.is_online
					UI.openURL "http://igd-labs.github.io/Groundhog/doc/file.ImportResults.html"
				elsif
					UI.messagebox("Sorry, documentation is only available when you are online... we really want to solve this")
				end
			}

	# Add the About.
	groundhog_menu.add_item("About Groundhog"){
		UI.messagebox "Groundhog version "+Sketchup.extensions["Groundhog"].version.to_s+"\n\nCreator:\n"+Sketchup.extensions["Groundhog"].creator+"\n\nCopyright:\n"+Sketchup.extensions["Groundhog"].copyright
	}

