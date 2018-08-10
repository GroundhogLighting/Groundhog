module GH
    module Groundhog
        

        # This class is the Observer of the Photosensors, allowing
        # the UI to update when changing the model. Bidirectional binding,
        # basically
        class PhotosensorObserver < Sketchup::EntityObserver
            
            # onErase function.
            # @author Germán Molina
            # @param entity [Sketchup::Entity] the modified Phososensor entity
            def onEraseEntity(entity)
                definitions = Sketchup.active_model.definitions.select{|x| Labeler.photosensor? x}
                names = definitions[0].instances.map{|x| Labeler.get_name(x)}

                script = "trimByName(#{names.inspect},photosensors);"
                GH::Groundhog::design_assistant.execute_script(script)                
            end

            # onChangeEntity function.
            # @author Germán Molina
            # @param entity [Sketchup::Entity] the modified Phososensor entity
            def onChangeEntity(entity)
                return if entity.deleted?                 
                j = Photosensor.get_json(entity)                
                GH::Groundhog::design_assistant.execute_script("updateByName(photosensors,#{j});")                
            end

        end


    end
end