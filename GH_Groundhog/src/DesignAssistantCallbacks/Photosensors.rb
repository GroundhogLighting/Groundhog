module GH
    module Groundhog
        module DesignAssistant

            def self.enable_photosensor_tool(wd)
                wd.add_action_callback("enable_photosensor_tool") do |action_context,msg|         
                    Sketchup.active_model.select_tool SetPhotosensorTool.new
                end
            end

            def self.load_photosensors(wd)
                wd.add_action_callback("load_photosensors") do |action_context,msg|         
                    # Get all photosensors
                    definitions = Sketchup.active_model.definitions.select{|x| Labeler.photosensor? x}
                    if definitions.length > 0 then
                        script = ""
                        definitions[0].instances.each{|i|
                            j = Photosensor.get_json(i)
                            script += "updateByName(photosensors,#{j});"
                        }
                        
                        GH::Groundhog::design_assistant.execute_script(script)                
                    end
                    
                end
            end

            def self.add_photosensor(wd)
                wd.add_action_callback("add_photosensor") do |action_context,msg|                                                 
                    Photosensor.add(msg)                    
                end
            end

            def self.remove_photosensor(wd)
                wd.add_action_callback("delete_photosensor") do |action_context,msg|
                    Photosensor.delete(msg)
                end
            end

            

        end
    end
end