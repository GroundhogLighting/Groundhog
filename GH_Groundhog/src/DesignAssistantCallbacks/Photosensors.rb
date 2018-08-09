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
                    
                end
            end

            def self.add_photosensor(wd)
                wd.add_action_callback("add_photosensor") do |action_context,msg|         
                    Photosensor.add(msg)
                    Error.log "Photosensor was added"
                end
            end

            def self.remove_photosensor(wd)
                wd.add_action_callback("remove_photosensor") do |action_context,msg|
                    Photosensor.delete(msg)
                end
            end

            

        end
    end
end