
class GH_AddWorkplane
	
	
	

	# @author German Molina
	def self.add_Workplanes
		model=Sketchup.active_model
		
		sel=model.selection
		ent=model.entities
		non_h=false			
		h=0.8.m #Default workplane height
		
		
		begin
			op_name = "Add Workplane"
		  	model.start_operation( op_name )
			
			wps=[] #to store the final workplanes
			
			sel.each do |face|	
				nor=face.normal.transform! -h #this is the distance to move each vertex
				if GH_Labeler.face?(face) then #if is not a face, nothing happens.
					up=Geom::Vector3d.new(0,0,1)
					if nor.parallel?(up) then
						
						if not nor.samedirection? up then
							nor.reverse! 
						end
						
						pts=[] #vertices of the new plane
						vertices=face.vertices #Vertices of the old plane
						vertices.each do |v| #calculate the new positions
							pt=v.position
							pts=pts+[pt+nor]
						end
				
						plane=ent.add_face pts
						plane.material=[1.0,0.0,0.0]
						plane.material.alpha=0.2
						plane.back_material=[1.0,0.0,0.0]
						plane.back_material.alpha=0.2
						plane.set_attribute("Groundhog","Label","workplane")
						wps=wps+[plane]
					else
						non_h=true
					end
				end
			end
			
			GH_Labeler.set_name(wps)
	
			if non_h then
				UI.messagebox("Non horizontal planes were not considered")
			end
			
		  	model.commit_operation
		rescue => e
			model.abort_operation
		  	
		#else
		  #
		  # Do code here ONLY if NO errors occur.
		  #
		#ensure
		  #
		  # ALWAYS do code here errors or not.
		  #
		end
			
	end
	
	

end