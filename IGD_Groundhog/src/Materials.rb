module IGD
	module Groundhog
		module Materials

			# Adds the default material to the model
			# @author German Molina
			# @return [Void]
			def self.add_default_material
				#Add the default materials to the model
				Sketchup.active_model.materials.add "GH_default_material"
				Sketchup.active_model.materials["GH_default_material"].color=[0.7,0.7,0.7]
				Labeler.to_rad_material(Sketchup.active_model.materials["GH_default_material"])
				val = {"rad" => "void plastic %MAT_NAME% 0 0 5 0.6 0.6 0.6 0 0"}
				Labeler.set_rad_material_value(Sketchup.active_model.materials["GH_default_material"],val.to_json)
			end

			# Adds the glass material to the model
			# @author German Molina
			# @return [Void]
			def self.add_default_glass
				Sketchup.active_model.materials.add "GH_default_glass"
				Sketchup.active_model.materials["GH_default_glass"].color=[0.0,0.0,1.0]
				Sketchup.active_model.materials["GH_default_glass"].alpha=0.2
				Labeler.to_rad_material(Sketchup.active_model.materials["GH_default_glass"])
				val = {"rad" => "void glass %MAT_NAME% 0 0 3 0.86 0.86 0.86"}
				Labeler.set_rad_material_value(Sketchup.active_model.materials["GH_default_glass"], val.to_json)
			end

			# Returns the Radiance primitive of a SketchUp material.
			#  It first checks if it is available in the library, and if not, it guesses it.
			#  If inputted a name (instead of "False"), the primitive's name will be forced to be
			#  the inputted value. This is useful for exporting components.
			# @author German Molina
			# @version 0.4
			# @param material [Sketchup::Material] SketchUp material
			# @param name [String] The desired name for the final Radiance material
			# @return [String] Radiance primivite definition for the material
			def self.get_mat_string(material,name)
				matName=Utilities.fix_name(material.name)
				matName=Utilities.fix_name(name) if name #if inputted a name, overwrite.

				if Labeler.rad_material?(material) then
					# if it is a rad_material, get the value... and verify it
					value = Labeler.get_value(material)
					if value == nil then
						UI.messagebox "rad_material without value!"
						return false
					end
					value=JSON.parse(value)
					if value["rad"] == nil then
						UI.messagebox "rad_material with incorrect value! no 'rad' field"
						return false
					end
					File.open("#{matName}.mat",'w'){|f| f.puts value["rad"].gsub("%MAT_NAME%", matName) }										
					return "!xform ./Materials/#{matName}.mat"
				else #not local, then guess the material
					mat_string=""

					if material.texture==nil then
						color=material.color
					else
						color=material.texture.average_color
					end
					r=color.red/255.0
					g=color.green/255.0
					b=color.blue/255.0

					mat_string=mat_string+"## guessed Material\n\n"
					if material.alpha < 1 then #then this is a glass
						r=r*material.alpha #This is probably wrong... but it does the job.
						g=g*material.alpha
						b=b*material.alpha
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s
						mat_string=mat_string+"void\tglass\t"+matName+"\n0\n0\n3\t"+rgb+"\n"
					else #This is an opaque material
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s+"\t0\t0"
						mat_string=mat_string+"void\tplastic\t"+matName+"\n0\n0\n5\t"+rgb+"\n"
					end
					return mat_string
				end

			end


=begin
			# Opens the materials wizard web dialog and adds the appropriate action_callback
			#
			# @author German Molina
			# @return [Void]
			# @version 0.1
			def self.show_material_wizard
				wd=UI::WebDialog.new(
					"Materials", false, "",
					530, 450, 100, 100, true )

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
			# @param argument [String]
			# @return [String] Nice material definition
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

			# Adds a material to the model based on a JSON (Hash) inputed.
			#  This JSON is meant to be sent by a web dialog.
			#
			# @author German Molina
			# @param material_JSON [Hash]
			# @return [Boolean] Success
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
				rescue Exception => ex
					UI.messagebox ex
					model.abort_operation
					return false
				end
			end
=end



		end
	end
end
