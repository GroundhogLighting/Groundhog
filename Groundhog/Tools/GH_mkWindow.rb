# Tool GH_MkWindow {http://www.sketchup.com/intl/en/developer/docs/ourdoc/tool.php 
# (SketchUp requires Tools to be defined as a special class, with 
# specific methods)}
#
# This Tool makes a whole trough a wall in order to make a window.
#
# It Labels the exterior surface as a "window", and creates an "illum" inside the wall, 
# that will be exported lately.

# @todo I want to make this tool more flexible... allowing putting the window more deeply inside
#   the wall ("deep" parameter in "activate" source code) by using onUserText function. 
#   I could not do this to run fluidly.
# @todo ... it does not deactivate itself.

class GH_MkWindow
	
	
	# Deactivate tool
	def deactivate(view)
		return nil
	end
	
	# Activate Tool
	# @author German Molina
	def activate
		@deep=0.01.m
		
		model=Sketchup.active_model
		entities=model.entities
		faceArray=GH_Utilities.get_faces(model.selection)
		winArray=GH_Utilities.get_windows(model.selection)


		begin
		  op_name = "Make Windows"
		  model.start_operation( op_name )
		
			if faceArray.length != winArray.length then # Do this only if there are faces that are not windows selected.
			
				faceArray.each do |i|	
					dir=i.normal.reverse.normalize
					edges=i.edges
				
					orig=i.vertices
					en=orig
					win=orig
					for k in 0..edges.length-1
						orig[k]=edges[k].vertices[0]
						en[k]=model.raytest(orig[k],dir)[0]
			
						or1=edges[k].vertices[0].position
						or2=edges[k].vertices[1].position
						en1=model.raytest(or1,dir)[0]
						en2=model.raytest(or2,dir)[0]
			
						entities.add_face(or1, en1, en2, or2)
					end
		
					#Add an illum
					rem=entities.add_face(en)
					GH_Labeler.to_illum([rem])		
						
					orig=i.vertices
					pts2=[]
					dir.length=0.01.m
					orig.each do |v|
						ax=v.position.+dir
						pts2=pts2+[ax]
					end
					newf=entities.add_face(pts2)
					GH_Labeler.to_window([newf])
					newf.reverse!
					entities.erase_entities(i)

				end
			end

		
		
			model.commit_operation
		rescue => e
			model.abort_operation
			UI.messagebox("Operation failed... please contact us to tell us what happened.\n\nTHANKS.")
		#else
		  #
		  # Do code here ONLY if NO errors occur.
		  #
		#ensure
		  #
		  # ALWAYS do code here errors or not.
		  #
		end

			
		

	end #end of activate method
	
	
end #End of class
