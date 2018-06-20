module GH
    module Groundhog
        module DesignAssistant

            def self.load_materials(wd)
                wd.add_action_callback('load_materials'){|action_context,tasks|
                    mats = Sketchup.active_model.materials.select{|x| Labeler.is_labeled?(x,MATERIAL)}                        
                    mats.each{|mat|                                                
                        Utilities.push_material_to_ui(mat)
                    }
                }
            end # end of load_materials

            def self.add_material(wd)
                wd.add_action_callback('add_material'){|action_context,mat|
                    Utilities.add_material(mat)
                }
            end # end of add_materials
            
            def self.edit_material(wd)
                wd.add_action_callback('edit_material'){|action_context,mat|
                    # Parse the data
                    new_mat = JSON.parse(mat)
                    old_name = new_mat['oldName']
                    new_name = new_mat['name']
                    new_mat.delete('oldName') 

                    # Find material
                    materials = Sketchup.active_model.materials                    
                    old_mat = materials[old_name]

                    # Update name
                    if old_name != new_name then
                        old_mat.name = new_name
                        materials.remove(old_name) if materials[old_name] != nil
                    end
                    # Update color
                    old_mat.color=[new_mat["color"]['r'],new_mat["color"]['g'],new_mat["color"]['b']].map{|x| (x.to_f*255).to_i}

                    # Update value
                    new_mat['class'] = new_mat['class'].downcase
                    Labeler.set_value(old_mat,new_mat.to_json)

                }
            end # end of edit_material

            def self.delete_material(wd)
                wd.add_action_callback('delete_material'){|action_context,matName|
                    materials = Sketchup.active_model.materials
                    materials.remove(materials[matName]) if materials[matName] != nil
                }
            end # end of delete_material
            
            def self.use_material(wd)
                wd.add_action_callback('use_material'){|action_context,material|
                    materials = Sketchup.active_model.materials
                    m = JSON.parse(material)
                    name = m["name"]
                    if materials[name] == nil then #add it if it does not exist
                        Utilities.add_material(m)
                    end
                    Sketchup.send_action("selectPaintTool:")
                    materials.current=materials[name]
                }
            end # end of use_material
            


        end
    end
end