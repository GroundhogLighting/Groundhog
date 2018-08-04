module GH
    module Groundhog
        module DesignAssistant

            def self.load_workplanes(wd)
                wd.add_action_callback("load_workplanes"){ |action_context,wp_name|
                    # Get registry
                    Utilities.get_workplanes_registry.each{|wp|
                        Utilities.push_workplane_to_ui(wp)
                    }
                }
            end # end of load_workplanes

            def self.remove_workplane(wd)
                wd.add_action_callback("remove_workplane"){ |action_context,wp_name|                    
                    Utilities.remove_workplane(wp_name)
                }
            end # End of remove_workplane

            def self.edit_workplane(wd)
                wd.add_action_callback("edit_workplane"){|action_context,msg|
                    
                    # Parse the data
                    new_workplane = JSON.parse(msg)
                    old_name = new_workplane['oldName']
                    new_name = new_workplane['name']
                    new_workplane.delete('oldName')
                    new_workplane['pixel_size']=new_workplane['pixel_size'].to_f

                    # Edit surfaces in the model
                    if old_name != new_name then
                        Sketchup.active_model.start_operation('rename workplane surfaces')                        
                        faces = Utilities.get_workplane_by_name(old_name)
                        faces.each{|f|
                            f.set_attribute(GROUNDHOG_DICTIONARY,NAME_KEY,new_name)
                        }
                        Sketchup.active_model.commit_operation
                    end

                    # Change registry in dictionary                    
                    value = Utilities.get_workplanes_registry
                    value.each_with_index{|wp,i|                        
                        if wp['name'] == old_name then
                            value[i] = new_workplane
                            break
                        end
                    }
                    Utilities.set_workplanes_registry(value)
                }
            end # End of edit_workplane

            
        end # End of DesignAssistant module
    end # End of Groundhog module
end # End of GH module