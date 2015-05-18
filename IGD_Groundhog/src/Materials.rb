module IGD
	module Groundhog
		module Materials
			
			# Adds the default material to the model
			# @author German Molina
			# @param entities [Array]
			def self.add_default_material
				#Add the default materials to the model
				Sketchup.active_model.materials.add "GH_default_material"
				Sketchup.active_model.materials["GH_default_material"].color=[0.7,0.7,0.7]
				Labeler.to_local_material(Sketchup.active_model.materials["GH_default_material"])
				Labeler.set_local_material_value(Sketchup.active_model.materials["GH_default_material"],["void\tplastic","\n0\n0\n5\t0.6\t0.6\t0.6\t0\t0"])
			end

			# Adds the glass material to the model
			# @author German Molina
			# @param entities [Array]			
			def self.add_default_glass
				Sketchup.active_model.materials.add "GH_default_glass"
				Sketchup.active_model.materials["GH_default_glass"].color=[0.0,0.0,1.0]
				Sketchup.active_model.materials["GH_default_glass"].alpha=0.2	
				Labeler.to_local_material(Sketchup.active_model.materials["GH_default_glass"])
				Labeler.set_local_material_value(Sketchup.active_model.materials["GH_default_glass"],["void\tglass","\n0\n0\n3\t0.86\t0.86\t0.86"])
			end

			# Opens the materials wizard web dialog and adds the appropriate action_callback
			#
			# @author German Molina
			# @param void
			# @return void
			# @version 0.1	
			def self.show_material_wizard
				wd=UI::WebDialog.new( 
					"Materials", false, "", 
					530, 450, 100, 100, false )

				wd.set_file("#{OS.main_groundhog_path}/src/html/materials_wizard.html" )

				wd.add_action_callback("get_material_JSON") do |web_dialog,msg|
					material_JSON=JSON.parse(msg)
					self.process_material_JSON(material_JSON)
				end
		
				wd.show()
			end
			
			# Receives a material definition with no new lines and makes it
			# nicer, with new lines and tabs... easier to read.
			#
			# @author German Molina
			# @param material_definition [String]
			# @return nice_material_definition [String]
			# @version 0.1	
			def self.parse_material_argument(argument)
				ret=""
				arr=argument.split(" ")
				#first line
#				ret+=arr.shift+"\t"+arr.shift+"\t"+arr.shift
				
				for k in 0..2 #three times... one for each line.
					ret+="\n"
					n=arr.shift
					ret+=n
					n=n.to_i
					for i in 0..n-1
						ret+="\t"
						ret+=arr.shift
					end
				end
						
				return ret
			end

			# Receives a material definition with no new lines and makes it
			# nicer, with new lines and tabs... easier to read.
			#
			# @author German Molina
			# @param material_definition [String]
			# @return nice_material_definition [String]
			# @version 0.1	
			def self.process_material_JSON(material_JSON)
				name=material_JSON["name"]
				red=material_JSON["red"]
				green=material_JSON["green"]
				blue=material_JSON["blue"]					
				alpha=material_JSON["alpha"]					
				
				#check if it exists
				mat=Sketchup.active_model.materials[name] 
				if mat!=nil then #error if it exists
					answer=UI.messagebox("There is already a material with that name in the model.\n\nWould you like to overwrite it?",MB_YESNO)
					return false if answer == IDNO
				end
				
				begin
					model=Sketchup.active_model
					op_name = "Add material"
					model.start_operation( op_name,true )
		
					mat = Sketchup.active_model.materials.add name if mat == nil
					mat.color=[red,green,blue]
					mat.alpha=alpha
					
					Labeler.to_local_material(mat)
					Labeler.set_local_material_value(mat,[material_JSON["mod_type"],self.parse_material_argument(material_JSON["argument"])])					
					
					model.commit_operation
					return true
				rescue => e
					model.abort_operation
					OS.failed_operation_message(op_name)
					return false
				end		
			end	
	
	
		end
	end
end