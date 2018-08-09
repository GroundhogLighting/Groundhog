module GH
    module Groundhog


        # This tool allows a better user experience. It is enabled
        # when clicking the "add photosensor" button. It helps
        # choosing the position by clicking the model directly.
        # @author Germán Molina
        class SetPhotosensorTool
            
            @@inputpoint = Geom::Point3d.new(0,0,0)
            @@normal = Geom::Vector3d.new(0,0,1)

            # activate Method. This is called when the 
            # tool is activated.
            # 
            # @author Germán Molina
            def activate
                Sketchup.set_status_text "Click on your model to choose the location of the photosensor", SB_PROMPT
            end

            # On Draw method... this draws the temporary sensor  
            # so the user can know where is it being placed
            # 
            # @param view [Sketchup::View] This is required by the Tool class
            # @author Germán Molina
            def draw(view)
                aux_vector = Geom::Vector3d.new(1,1,1)  
                aux_vector =  Geom::Vector3d.new(3,2,3) if aux_vector.parallel? @@normal
                e1 =  @@normal.cross(aux_vector)
                e2 = @@normal.cross(e1)                
                n_points = 6 # number of vertices per quarter circle
                r = 0.06.m
                q = 0
                4.times{|i|
                    points = [@@inputpoint]                    
                    (n_points + 1).times{|a|                        
                        t = q.to_f/n_points/4
                        d1 = e1.clone
                        d2 = e2.clone
                        d1.length = r * Math.cos(2*Math::PI * t)
                        d2.length = r * Math.sin(2*Math::PI * t)
                        points << (@@inputpoint + d1 + d2 )                        
                        # rotate
                        q += 1
                    } 
                    q -= 1
                    view.line_stipple = '' # Solid line
                    view.drawing_color = Sketchup::Color.new(0,0,0)                                        
                    view.draw(GL_LINE_LOOP, points)

                    view.drawing_color = Sketchup::Color.new(145, 31, 21) if i%2 == 0                    
                    view.drawing_color = Sketchup::Color.new(255, 255, 255) if i%2 != 0
                    view.draw(GL_POLYGON , points)
                }
                                
                
            end

            # On click witht the mouse, we update the location of th click as well 
            # as the normal of the sensor (i.e. the normal of the surface)
            #
            # @author Germán Molina
            # param flags [Unkown] Required by Tool class            
            # param x [Numeric] Required by Tool class... the x coordinate of the mouse in the screen
            # param y [Numeric] Required by Tool class... the y coordinate of the mouse in the screen
            # param view [Sketchup::View] Required by Tool class... the current view
            def onLButtonUp(flags, x, y, view)
                h = view.pick_helper
                h.do_pick(x,y)
                face = h.picked_face
                if face then                    
                    @@normal = face.normal
                    v_direction = view.camera.direction
                    @@normal.reverse! if @@normal % v_direction > 0
                    s_n = @@normal.clone
                    s_n.length = 0.015.m                    
                    @@inputpoint = view.inputpoint(x,y).position + s_n
                                        
                    script = ""
                    script += "selected_photosensor.dx=#{@@normal.x};"
                    script += "selected_photosensor.dy=#{@@normal.y};"
                    script += "selected_photosensor.dz=#{@@normal.z};"
                    script += "selected_photosensor.px=#{@@inputpoint.x.to_m};"
                    script += "selected_photosensor.py=#{@@inputpoint.y.to_m};"
                    script += "selected_photosensor.pz=#{@@inputpoint.z.to_m};"

                    view.refresh    
                    GH::Groundhog.design_assistant.execute_script(script)  
                                            
                end
            end            

        end # end TOOL 

        # This class is the Observer of the Photosensors, allowing
        # the UI to update when changing the model. Bidirectional binding,
        # basically
        class PhotosensorObserver < Sketchup::EntityObserver
            
            # onErase function.
            # @author Germán Molina
            # @param entity [Sketchup::Entity] the modified Phososensor entity
            def onEraseEntity(entity)
                #DesignAssistant.update
            end

            # onChangeEntity function.
            # @author Germán Molina
            # @param entity [Sketchup::Entity] the modified Phososensor entity
            def onChangeEntity(entity)
                #DesignAssistant.update
            end

        end

		# This module has the methods that allow handling photosensors.
        module Photosensor

            @@photosensor_name = "GH Photosensor"
            

            # Returns a hash with data corresponding to location and orientation of 
            # the photosensor
            # @author Germán Molina
            # @return [Hash] The position
            # @param sensor [Sketchup::ComponentInstance] the sensor
            def self.get_position(sensor)
                ret = Hash.new
                vdir = sensor.transformation.zaxis
                ret["nx"] = vdir[0]
                ret["ny"] = vdir[1]
                ret["nz"] = vdir[2]
                pos = sensor.transformation.origin
                ret["px"] = pos[0].to_m
                ret["py"] = pos[1].to_m
                ret["pz"] = pos[2].to_m
                return ret
            end


            # Deletes a photosensor from the model.
            # @author Germán Molina
            # @param name [String] The name of the photosensor to delete            
            def self.delete(name)
                sensors = Sketchup.active_model.definitions.select {|x| IGD::Groundhog::Labeler.illuminance_sensor?(x) }
                if not sensors or sensors.length == 0 then
                    UI.messagebox("Error when trying to delete photosensor '#{name}'")
                    return false
                end
                named_equal = sensors[0].instances.select{|x| IGD::Groundhog::Labeler::get_name(x) == name }
                if not named_equal or named_equal.length == 0 then
                    UI.messagebox("Error when trying to delete photosensor '#{name}'")
                    return false
                end
                Sketchup.active_model.entities.erase_entities named_equal
                    
                return true
            end

            # Loads the Illuminance Sensor component to the model
            # @author German Molina
            # @version 0.1			
            # @param location_json [String] The JSON that comes from the UI
            # @return [Boolean] Sketchup::ComponentDefinition is success, false if not            
            def self.add(location_json)

                location = JSON.parse(location_json)    
                
                
                origin = Geom::Point3d.new(location["px"].to_f.m,location["py"].to_f.m,location["pz"].to_f.m)
                zaxis = Geom::Vector3d.new(location["dx"].to_f,location["dy"].to_f,location["dz"].to_f)                
                transformation = Geom::Transformation.new(origin,zaxis)

                sensors = Sketchup.active_model.definitions.select {|x| Labeler.photosensor?(x) }

                # Load it if it is not there                
                if sensors.length < 1 then                   
                    
                    sensor = Loader.load_local_component("photosensor")                    
                    return false if not sensor                    
                    sensor.name=@@photosensor_name                    
                    sensor.description="This represents an illumiance sensor."                    
                    sensor.casts_shadows= false                    
                    sensor.receives_shadows= false                    
                    Labeler.to_photosensor(sensor)

                else
                    # if it exists, we may need to move.
                    named_equal = sensors[0].instances.select{|x| Labeler::get_name(x) == location["name"]}
                    if named_equal.length > 0 then #move instead of add
                        # We assume there is only one.
                        named_equal[0].transformation = (transformation)                        
                        return true
                    end
                end                   

                # add if not
                sensor = Sketchup.active_model.definitions[@@photosensor_name]                          
                instance = Sketchup.active_model.entities.add_instance(sensor, transformation)                
                Labeler.set_name([instance],location["name"])
                instance.add_observer(PhotosensorObserver.new)  
                Labeler.to_photosensor(instance)
                Sketchup.active_model.active_view.refresh                
                return true
            end

        end
    end
end