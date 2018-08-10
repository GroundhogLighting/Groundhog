module GH
    module Groundhog
  
  
        class WorkplaneObserver < Sketchup::EntityObserver
          def onEraseEntity(entity)
            #deleted entities have no name, so we need to do it like this.            
            #get the names of all the workplanes in the model
            workplanes = Utilities.get_workplanes(Sketchup.active_model.entities)
            workplanes = workplanes.map{|x| Labeler.get_name(x)}.uniq
  
            value = Utilities.get_workplanes_registry                    

            # Guess the name of the workplane.                                            
            value.each_with_index{|wp,i|                                                         
                if not workplanes.include? wp['name'] then                       
                    # If it is not there, it means that the WP needs to be unregistered                        
                    Utilities.unregister_workplane(wp['name'])

                    # And popped from UI
                    Utilities.pop_workplane_from_ui(wp["name"])
                    return
                end
            }
        

                                                       
          end
  
          # This works... but I forgot what I needed it for?
          # CHANGING NAME is solved in the set_name method
          #def onChangeEntity(entity)
          #  return if entity.deleted?
          #  warn Labeler.get_name(entity)
          #end
        end
  
        
    end
  end
  