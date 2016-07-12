module IGD
	module Groundhog
		
		# This module handles everything related to the Materials.
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
			#
			#  If xform == true (and if it is a rad_material), a file will be written dedicated to the material
			#	 and the return value will be the !xform ... line needed for referencing it.
			#
			# @author German Molina
			# @version 0.4
			# @param material [Sketchup::Material] SketchUp material
			# @param name [String] The desired name for the final Radiance material
			# @param xform [Boolean] reference the material by Xform
			# @return [String] Radiance primivite definition for the material
			def self.get_mat_string(material,name, xform)
				mat_name=Utilities.fix_name(material.name)
				mat_name=Utilities.fix_name(name) if name #if inputted a name, overwrite.

				mat_string=""

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
					mat_string = value["rad"].gsub("%MAT_NAME%", mat_name)					
				else #not rad_material, then guess the material	
					warn "#{mat_name} guessed!"				
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
						mat_string=mat_string+"void\tplastic\t"+mat_name+"\n0\n0\n5\t"+rgb+"\n"
					end					
				end

				if xform then
					File.open("#{mat_name}.mat",'w'){|f| f.puts mat_string }										
					return "!xform ./Materials/#{mat_name}.mat"
				else
					return mat_string
				end

			end




		end
	end
end
