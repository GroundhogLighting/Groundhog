module IGD
	module Groundhog
		# Tool GH_MkWindow {http://www.sketchup.com/intl/en/developer/docs/ourdoc/tool.php 
		# (SketchUp requires Tools to be defined as a special class, with 
		# specific methods)}
		#
		# This Tool makes a whole trough a wall in order to make a window.
		#
		# It Labels the exterior surface as a "window", and creates an "illum" inside the wall, 
		# that will be exported lately.


		module MkWindow
	
			def self.make_window(faces)

				winArray=Utilities.get_windows(faces)
				return false if faces.length == winArray.length # Do this only if there are faces that are not windows selected.
				model=Sketchup.active_model
				entities=model.entities
				begin
					op_name = "Make Windows"
					model.start_operation( op_name,true )
				
					some_were_far=false
					some_were_close=false
					some_did_not_hit=false
				
					close=0.01.m
					far=0.7.m
				
					every_window=[]
					every_illum=[]
					every_thickness=[]
					every_face=[]
					every_transformed_window=[]
				
					faces.each do |face|	
						next if Labeler.window?(face)
						next if face.loops.count!=1 #windows with wholes
					
						did_not_hit=false #in case the ray-test does not hit anything.
						too_far=false #in case the ray-test hits something too far.
						too_close=false
					
						dir=face.normal.reverse.normalize
						dir2=dir
						dir2.length=close
						edges=face.edges
					
					
						thickness=[] #the border of the window.
						window=[]
						illum=[]
					
						edges.each do |edge|
							vertices=edge.vertices
							a=vertices[0].position
							d=vertices[1].position
							b=model.raytest([a,dir],false)
							c=model.raytest([d,dir],false)
							if b==nil or c==nil then
								did_not_hit=true
								break
							end
							b=b[0]
							c=c[0]
						
							#notices that there are walls that are too thick, or an error
							too_far=true if a.distance(b) > far or c.distance(d) > far 
							too_close = true if a.distance(b) <= close or c.distance(d) <= close
						
							#build illum and window
							illum.push(b) 
							window.push(a.+dir2)
						
							#add the thickness
							thickness.push([a,b,c,d]) 
									
						end
					
						#notice that at least one hit was far
						some_were_far = true if too_far
						some_were_close = true if too_close
						some_did_not_hit = true if did_not_hit
					
						#store for transformation, not for building
						if too_far or too_close or did_not_hit then
							every_transformed_window.push(face)
							next
						end	
					
						#add everything to the "to do" list
						every_face.push(face)
						every_thickness.push(thickness)
						every_window.push(window)
						every_illum.push(illum)
					
					end

					if some_were_far or some_were_close or some_did_not_hit then
						msg="Some of the windows you want to create present some anomalies.\n\n"
						msg+="There might be an error, unless you are working with:\n"
						msg+="\t-Walls with no thickness (i.e. thinner than #{close.to_m}m)\n"
						msg+="\t-Walls that are too thick (i.e. thicker than #{far.to_m}m)\n"
						msg+="\nWould you like to create them anyway?"
						input=UI.messagebox(msg,MB_YESNO)
						if input==IDYES then
							UI.messagebox("You might want to look into the Right-Click --> 'Label as window' alternative.")
						else
							return 
						end
					end
		
					#delete original face
					every_face.each do |fc|
						entities.erase_entities(fc)
					end
			
					#add thickness
					every_thickness.each do |thk|
						thk.each do |thick|
							entities.add_face(thick)
						end
					end
									
					#add window
					every_window.each do |wn|
						Labeler.to_window([entities.add_face(wn)])
					end
				
					#add illum
					every_illum.each do |ill|
						Labeler.to_illum([entities.add_face(ill)])
					end	
				
					#transform some windows
					every_transformed_window.each do |wn|
						Labeler.to_window([wn])
					end		

				
				rescue => e
					model.abort_operation
					OS.OS.failed_operation_message(op_name)
				#else
				  #
				  # Do code here ONLY if NO errors occur.
				  #
				#ensure
				  #
				  # ALWAYS do code here errors or not.
				  #
				end

			
		

			end #end of method
	
	
		end #End of class
	end #end module
end