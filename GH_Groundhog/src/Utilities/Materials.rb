
module GH
    module Groundhog
        module Utilities
            
            # Creates a SketchUp material from the Groundhog definition.
			# If the material already exist, it will update it (by default, SketchUp
			# adds a second material with the same name followed by a number)
            #
            # @author German Molina
			# @param m [Hash] The material hash
			def self.add_material(m)
				m = JSON.parse(m) if m.is_a? String				
				materials = Sketchup.active_model.materials
				
                materials.add m["name"] if materials[m["name"]] == nil #add it if it does not exist
				mat = materials[m["name"]]
				mat.color=[m["color"]['r'],m["color"]['g'],m["color"]['b']].map{|x| (x*255).to_i}
				
				mat.alpha=1 # default is opaque
				if m['class'] == 'glass' then
					# Do something with Alpha
					
				end
				
				Labeler.label_as(mat, MATERIAL)
				Labeler.set_value(mat,m.to_json)
			end

            # Push a material in Hash format to the UI
			#
			# @author German Molina
			# @param mat [Sketchup::Material] The material
			def self.push_material_to_ui(mat)												
				v = Labeler.get_value(mat)
				if v then
					v = JSON.parse(v) 
				else                            
					Error.inform_exception "A material labeled as Radiance material ha no value!"
				end
				
				script = "var m = materials.find(function(m){m.name === '#{v['name']}'});if(!m){materials.push(#{v.to_json})};"				
				GH::Groundhog.design_assistant.execute_script(script)
            end
            
            # Removes a material from the UI
			#
			# @author German Molina
			# @param name [String] The Material's name
			def self.pop_material_from_ui(name)
				script = ""					
				script += "var i = materials.findIndex(function(t){return t.name === '#{name}'});"					
				script += "if(i >= 0){materials.splice(i,1)};"					
				GH::Groundhog.design_assistant.execute_script(script) 
            end
        end
    end
end