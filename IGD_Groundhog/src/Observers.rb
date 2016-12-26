module IGD
  module Groundhog


      class WorkplaneObserver < Sketchup::EntityObserver
        def onEraseEntity(entity)
          #deleted entities have no name, so we need to do it lke this.

          #get the names of all the workplanes in the model
          workplanes = Utilities.get_workplanes(Sketchup.active_model.entities).map{|x| Labeler.get_name(x)}.uniq

          # Un-register the workplane.
          model = Sketchup.active_model
          value = model.get_attribute("Groundhog","workplanes")
          Error.inform_exception("Model has no registered workplanes!") if value == nil or not value
          value = JSON.parse value
          value.keys.each{|wp_name|
            value.delete(wp_name) if not workplanes.include? wp_name
          }
          model.set_attribute("Groundhog","workplanes",value.to_json)
          DesignAssistant.update
        end


        def onChangeEntity(entity)
          warn Labeler.get_name(entity)
        end


      end
  end
end
