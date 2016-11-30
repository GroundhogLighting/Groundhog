module IGD
	module Groundhog

		# This module handles everything related to the Materials.
		module Materials

			# Creates a SketchUp material from the Groundhog definition.
			# If the material already exist, it will update it (by default, SketchUp
			# adds a second material with the same name followed by a number)
			# @author German Molina
			# @param m [Hash] The material hash
			def self.add_material(m)
				materials = Sketchup.active_model.materials
				m["color"] = m["color"].map{|x| x.to_i}
				m["alpha"] = m["alpha"].to_f
				materials.add m["name"] if materials[m["name"]] == nil #add it if it does not exist
				mat = materials[m["name"]]
				mat.color=m["color"]
				mat.alpha=m["alpha"]
				Labeler.to_rad_material(mat)
				Labeler.set_rad_material_value(mat,m.to_json)
			end

			# Creates a SketchUp material from the Groundhog definition, but it is texture
			# to recognize it as the back side of the surface.
			# If the material already exist, it will update it (by default, SketchUp
			# adds a second material with the same name followed by a number)
			# @author German Molina
			# @param m [Hash] The material hash
			# @note Not all materials need a back version.
			def self.add_back_material(m)
				materials = Sketchup.active_model.materials
				m["color"] = m["color"].map{|x| x.to_i}
				m["alpha"] = m["alpha"].to_f
				m["name"] = m["name"]+" (back)"
				materials.add m["name"] if materials[m["name"]] == nil #add it if it does not exist
				mat = materials[m["name"]]
				mat.texture = "#{OS.main_groundhog_path}/Assets/Images/back_material_texture.jpg"
				mat.texture.size = 3
				mat.color=m["color"]
				mat.alpha=m["alpha"]
				Labeler.to_rad_material(mat)
				Labeler.set_rad_material_value(mat,m.to_json)
			end

			# Returns the hash that represents the Default Groundhog glass.
			# @author German Molina
			# @return [Hash] The material
			def self.default_glass
				return {"rad" => "void glass %MAT_NAME% 0 0 3 0.96 0.96 0.96", "color" => [0,0,255], "alpha" => 0.2, "name"=> "Default 3mm Clear Glass", "class" => "glass"}
			end


			# Returns the hash that represents the Default Groundhog material (opaque).
			# @author German Molina
			# @return [Hash] The material
			def self.default_material
				return {"rad" => "void plastic %MAT_NAME% 0 0 5 0.6 0.6 0.6 0 0", "color" => [153, 153, 153], "alpha" => 1, "name"=> "Default Material", "class" => "plastic"}
			end

			# Adds the default material to the model
			# @author German Molina
			# @return [Void]
			def self.add_default_material
				self.add_material self.default_material
			end

			# Adds the glass material to the model
			# @author German Molina
			# @return [Void]
			def self.add_default_glass
				self.add_material self.default_glass
				self.add_back_material self.default_glass
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
			def self.get_mat_string(material, name, xform)
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
					rad = value["rad"]
					if value["support_files"] then
						OS.mkdir("Materials/Cal")
						value["support_files"].each {|s|
							filename = s["name"]
							content = s["content"]
							given_name = mat_name+".cal"
							File.open("./Materials/Cal/"+given_name,'w+'){|f| f.puts content }
							rad = rad.gsub("%"+filename+"%", "./Materials/Cal/"+given_name)
						}
					end
					mat_string = rad.gsub("%MAT_NAME%", mat_name)
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
						mat_string=mat_string+"void\tglass\t"+mat_name+"\n0\n0\n3\t"+rgb+"\n"
					else #This is an opaque material
						rgb=r.to_s+"\t"+g.to_s+"\t"+b.to_s+"\t0\t0"
						mat_string=mat_string+"void\tplastic\t"+mat_name+"\n0\n0\n5\t"+rgb+"\n"
					end
				end

				if xform then
					File.open("Materials/#{mat_name}.mat",'w'){|f| f.puts mat_string }
					return "!xform ./Materials/#{mat_name}.mat"
				else
					return mat_string
				end

			end




		end
	end
end
