# MAIN
# Groundhog.RB

#################################

Sketchup::require 'Groundhog/GH_Utilities'
Sketchup::require 'Groundhog/GH_Labeler'
Sketchup::require 'Groundhog/GH_OS'
Sketchup::require 'Groundhog/Tools/GH_MkWindow'
#Sketchup::require 'Groundhog/Tools/GH_Render'
#Sketchup::require 'Groundhog/Tools/GH_AddWorkplane'
Sketchup::require 'Groundhog/GH_Exporter'


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




UI.add_context_menu_handler do |context_menu|
	context_menu.add_separator
end


gh_Toolbar=UI::Toolbar.new "Groundhog"


#rvu = UI::Command.new("rvu") { 
#   Rad.rvu
# }
# rvu.small_icon = "Icons/rvu.png"
# rvu.large_icon = "Icons/rvu.png"
# rvu.tooltip = "Interactive GH_Render"
# rvu.status_bar_text = "Interactive Renderer"
# rvu.menu_text = "Interactive Renderer"
 
mkWindow = UI::Command.new("mkWindow") { 
       Sketchup.active_model.select_tool GH_MkWindow.new
 }
 mkWindow.small_icon = "Icons/mkWindow.png"
 mkWindow.large_icon = "Icons/mkWindow.png"
 mkWindow.tooltip = "Makes a window"
 mkWindow.status_bar_text = "Makes a window"
 mkWindow.menu_text = "Makes a window"
 
  
#addWorkplane = UI::Command.new("addWorkplane") { 
#	GH_AddWorkplane.add_Workplanes
# }
# addWorkplane.small_icon = "Icons/addWorkplane.png"
# addWorkplane.large_icon = "Icons/addWorkplane.png"
# addWorkplane.tooltip = "Creates a workplane over a surface"
# addWorkplane.status_bar_text = "Creates a workplane over a surface"
# addWorkplane.menu_text = "Creates a workplane over a surface "
 
 #CFS are not yet supported.
#UI.add_context_menu_handler do |context_menu|
#   wins=GH_Utilities.get_windows(Sketchup.active_model.selection)
#	if wins.length>=1 then
#	   context_menu.add_item("Assign Complex Fenestration System") { 
#			GH_Labeler.assign_CFS(Sketchup.active_model.selection)
#	   }
#	end
#end

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

#UI.add_context_menu_handler do |context_menu|
#   faces=GH_Utilities.get_faces(Sketchup.active_model.selection)
#	if faces.length>=1 then
#	   context_menu.add_item("Label as Workplane") { 
#			GH_Labeler.to_workplane(faces)
#	   }
#	end
#end

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


file_menu = UI.menu "File"
file_menu.add_separator
file_menu.add_item("Export to Radiance") {
	GH_Exporter.export
}


#############################
 

gh_Toolbar = gh_Toolbar.add_item mkWindow
#gh_Toolbar = gh_Toolbar.add_item addWorkplane 
gh_Toolbar.show



extensions_menu = UI.menu "Plugins"
extensions_menu.add_item("Show Groundhog Toolbar") {
	gh_Toolbar.show
}

extensions_menu.add_item("About Groundhog"){
	UI.messagebox "Groundhog version "+Sketchup.extensions["Groundhog"].version.to_s+"\n\nCreator:\n"+Sketchup.extensions["Groundhog"].creator+"\n\nCopyright:\n"+Sketchup.extensions["Groundhog"].copyright
}

help_menu= UI.menu "Help"
help_menu.add_item("Full Groundhog documentation") {
	
	s=GH_OS.getsystem
	if Sketchup.is_online
		UI.openURL "http://groundhoglabs.github.io/Groundhog/doc/doc_index.html"
	elsif s=="MAC"
		UI.messagebox "Sorry, offline documentation is available on the '_index.html' file within the SketchUp's 'plugins/Groundhog/doc' directory.\n\nIf you know how to call that file directly, please let us know."
	elsif s=="WIN"
		UI.messagebox "Sorry, offline documentation is available on the '_index.html' file within the SketchUp's 'plugins/Groundhog/doc' directory.\n\nIf you know how to call that file directly, please let us know."
	end
}

view_menu=UI.menu "View"
view_menu.add_item("Show/Hide illums"){
	GH_Utilities.hide_show_specific("illum")	
}
view_menu.add_item("Show/Hide Workplanes"){
	GH_Utilities.hide_show_specific("workplane")	
}
view_menu.add_item("Show/Hide window groups"){
	Sketchup.active_model.select_tool GH_Render.new
}