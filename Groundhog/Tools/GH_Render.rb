# This class contains all the methods that will change the way SketchUp renders, with
# the objective of showing information (grouped windows, etc).

class GH_Render


	# This method should be used to go back to normal rendering... hopefully their assigned modifier
	# (although modifiers do not have color or texture yet).
	# author German Molina
	#def render_back_to_normal
	
	#	faces=GH_Utilities.get_faces(Sketchup.active_model.entities)
	#
	#	faces.each do |fc|
	#		if GH_Labeler.window?(fc) then
	#			fc.material=[0.0,0.0,1.0]
	#			fc.material.alpha=0.2
	#			fc.back_material=[0.0,0.0,1.0]
	#			fc.back_material.alpha=0.2
	#		elsif GH_Labeler.illum?(fc) then
	#			fc.material=[0.0,1.0,0.0]
	#			fc.material.alpha=0.2
	#			fc.back_material=[0.0,1.0,0.0]
	#			fc.back_material.alpha=0.2
	#		elsif GH_Labeler.workplane?(fc) then
	#			fc.material=[1.0,0.0,0.0]
	#			fc.material.alpha=0.2
	#			fc.back_material=[1.0,0.0,0.0]
	#			fc.back_material.alpha=0.2
	#		else
	#			fc.material=nil
	#			fc.back_material=nil				
	#		end
	#	end
	#end

	# This method shows or hides the different window groups in different colors.
	# @author German Molina
	def activate
		
		model=Sketchup.active_model
		
		op_name = "show window groups"
		model.start_operation( op_name )

		windows=GH_Utilities.get_windows(Sketchup.active_model.entities)
		groups=GH_Utilities.get_win_groups(windows)
		
		mats=[]

		groups.each do |h|
			mats=mats+[[rand(30)/30.0,rand(30)/30.0,rand(30)/30.0]]
		end
	
		windows.each do |win|
			
			mat=win.material
			if mat==nil then # If the face does not have a front material
				mat=win.back_material # the back material will be tested
			end
			if mat==nil then # If it does not have a Back material either
				mat=Sketchup.active_model.materials["GH_default_glass"] 
			end
	
			win.set_attribute("Groundhog","material",mat)
			gr=GH_Labeler.get_win_group(win)
			if gr==nil then
				aux=[rand(30)/30.0,rand(30)/30.0,rand(30)/30.0]
				win.material=aux
				win.back_material=aux
			else # if the window has a group
				i=0
				while i<groups.length do # we assign the correct color.
					if gr==groups[i] then
						win.material=mats[i]
						win.back_material=mats[i]
						break					
					end
					i+=1
				end
			end
		end	
		
		model.commit_operation
		
	end #end method

	# Deactivate tool
	def deactivate(view)
		windows=GH_Utilities.get_windows(Sketchup.active_model.entities)
		
		windows.each do |win|
			
			mat=win.get_attribute("Groundhog","material")
			if mat==nil then
				mat=Sketchup.active_model.materials["GH_default_glass"] 
			end
			
			win.material=mat
			win.back_material=mat
		end
		
		Sketchup.active_model.materials.purge_unused
		
	end
	
end #end class
