module IGD
    module Groundhog
        module DesignAssistant

            # Asks for a EPW or WEA file to be inputed.
			# @author German Molina
			# @return [String] The weather file path, False if not
			def self.ask_for_weather_file
				path = UI.openpanel("Choose a weather file", "c:/", "weather file (.epw, .wea) | *.epw; *.wea ||")
				return false if not path

				while path.split('.').pop!='epw' do
					UI.messagebox("Invalid file extension. Please input a WEA or EPW file")
					path = UI.openpanel("Choose a weather file", path, "*.epw; *.wea")
					return false if not path
				end

				return path
			end

            # Opens, reads and parses a weather file. The file gets fixed into the model
			# @author German Molina
			# @param path [String] the path to the weather file
			# @return void
			def self.set_weather(path)
				return false if not path
				if Sketchup.active_model.georeferenced? then
					result = UI.messagebox('This model is already georeferenced. Choosing a weather file will overwrite this location.Do you want to continue?', MB_YESNO)
					return false if result == IDNO
				end
				weather = Weather.parse_epw(path)
				Sketchup.active_model.set_attribute("Groundhog","Weather",weather.to_json)
				shadow_info = Sketchup.active_model.shadow_info
				shadow_info["City"]=weather["city"]
				shadow_info["Country"] = weather["country"]
				shadow_info["Latitude"] = weather["latitude"]
				shadow_info["Longitude"] = weather["longitude"]
				shadow_info["TZOffset"] = weather["timezone"]

				return true
			end

            def self.get_workplanes_json
                workplanes = Utilities.get_workplanes(Sketchup.active_model.entities)
                wp_hash = Hash.new
                workplanes.each { |wp|
                    value = Labeler.get_value(wp)
                    value = [] if value == nil or not value
                    wp_hash[Labeler.get_name(wp)] = value
                }
                return wp_hash.to_json
            end

            def self.get
                wd = UI::WebDialog.new("Design Assistant",false,"DAsistant",500,500,130,120,true)
		        wd.set_file("#{OS.main_groundhog_path}/src/html/design_assistant.html" )                

                wd.add_action_callback("on_load") do |web_dialog,msg|
                    script = ""                    
                    script += "workplanes = JSON.parse('#{self.get_workplanes_json}');"
                    script += "objectiveModule.update_objectives();"
                    script += "objectiveModule.update_dialog();"                    
                    weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
                    if weather != nil then
                        weather = JSON.parse(weather)
                        script = "document.getElementById('weather_city').innerHTML='#{weather["city"]}';"
                        script += "document.getElementById('weather_state').innerHTML='#{weather["state"]}';"
                        script += "document.getElementById('weather_country').innerHTML='#{weather["country"]}';"
                        script += "document.getElementById('weather_latitude').innerHTML='#{weather["latitude"]}';"
                        script += "document.getElementById('weather_longitude').innerHTML='#{weather["longitude"]}';"
                        script += "document.getElementById('weather_timezone').innerHTML='GMT #{weather["timezone"]}';"                        
                    end
                    web_dialog.execute_script(script)
                end

                wd.add_action_callback("set_weather_path") do |web_dialog,msg|
                    path = self.ask_for_weather_file
                    self.set_weather(path)
                    weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
                    if weather != nil then
                        weather = JSON.parse(weather)
                        script = "document.getElementById('weather_city').innerHTML='#{weather["city"]}';"
                        script += "document.getElementById('weather_state').innerHTML='#{weather["state"]}';"
                        script += "document.getElementById('weather_country').innerHTML='#{weather["country"]}';"
                        script += "document.getElementById('weather_latitude').innerHTML='#{weather["latitude"]}';"
                        script += "document.getElementById('weather_longitude').innerHTML='#{weather["longitude"]}';"
                        script += "document.getElementById('weather_timezone').innerHTML='GMT #{weather["timezone"]}';"
                        web_dialog.execute_script(script)
                    end
                end

                wd.add_action_callback("go_to_eplus_weathers") do |web_dialog,msg|
                    UI.openURL("http://www.energyplus.net/weather")
                end

                wd.add_action_callback("preview") do |web_dialog,msg| 
                    path=Sketchup.temp_dir                   
                    export = Exporter.export(path)
                    if not export then
                        UI.messagebox "Error while exporting... sorry"
                    end
                                        
                    FileUtils.cd(path) do   
                        script=[]                      
                        script << "oconv ./Materials/materials.mat ./scene.rad  ./Skies/sky.rad  #{Rad.gather_windows} #{Rad.gather_tdds} > octree.oct"
                        script << "rvu #{Config.rvu_options} -vf Views/view.vf octree.oct"
                        OS.execute_script(script)
						OS.clear_actual_path
                    end                                       
                end

                wd.add_action_callback("label_as_window") do |web_dialog,msg|
                    faces = Utilities.get_faces(Sketchup.active_model.selection)
                    begin
						op_name = "Label as Window"
						Sketchup.active_model.start_operation( op_name ,true)
						Labeler.to_window(faces)
						Sketchup.active_model.commit_operation
					rescue Exception => ex
						UI.messagebox ex
						Sketchup.active_model.abort_operation
					end
                end

                wd.add_action_callback("label_as_workplane") do |web_dialog,msg|
                    faces = Utilities.get_faces(Sketchup.active_model.selection)
                    begin
						op_name = "Label as Workplane"
						Sketchup.active_model.start_operation( op_name ,true)
						Labeler.to_workplane(faces)
                        script = ""                    
                        script += "workplanes = JSON.parse('#{self.get_workplanes_json}');"
                        script += "objectiveModule.update_objectives();"
                        script += "objectiveModule.update_dialog();"  
                        web_dialog.execute_script(script)
						Sketchup.active_model.commit_operation
					rescue Exception => ex
						UI.messagebox ex
						Sketchup.active_model.abort_operation
					end
                end

                wd.add_action_callback("label_as_illum") do |web_dialog,msg|
                    faces = Utilities.get_faces(Sketchup.active_model.selection)
                    begin
						op_name = "Label as illum"
						Sketchup.active_model.start_operation( op_name ,true)
						Labeler.to_illum(faces)
						Sketchup.active_model.commit_operation
					rescue Exception => ex
						UI.messagebox ex
						Sketchup.active_model.abort_operation
					end
                end

                wd.add_action_callback("use_material") do |web_dialog,msg|
                    materials = Sketchup.active_model.materials
                    m = JSON.parse(msg)                   
                    name = m["name"]
                    m["color"] = m["color"].map{|x| x.to_i}
                    m["alpha"] = m["alpha"].to_f
                    if materials[name] == nil then
                        mat = Sketchup.active_model.materials.add name
                        mat.color=m["color"]
                        mat.alpha=m["alpha"]
                        Labeler.to_rad_material(mat)
                        Labeler.set_rad_material_value(mat,m.to_json)
                    end                    
                    Sketchup.send_action("selectPaintTool:")
                    materials.current=materials[name]
                end

                wd.add_action_callback("remove_material") do |web_dialog,name|
                    materials = Sketchup.active_model.materials                                                                             
                    materials.remove(materials[name]) if materials[name] != nil
                end

                wd.add_action_callback("add_objective") do |web_dialog,msg|
                    obj = JSON.parse(msg)
                    selected_workplane = obj["workplane"]
                    objective = obj["objective"]
                    wps = Utilities.get_workplanes(Sketchup.active_model.entities)                                        
                    wps = wps.select{|x| Labeler.get_name(x)==selected_workplane} if selected_workplane != "all"
                                        
                    wps.each {|workplane|                        
                        value = Labeler.get_value(workplane)
                        value = [] if value==nil
                        value.push(objective)
                        Labeler.set_value(workplane, value)
                    }
                    script = ""                    
                    script += "workplanes = JSON.parse('#{self.get_workplanes_json}');"
                    script += "objectiveModule.update_objectives();"
                    web_dialog.execute_script(script)
                end

                wd.add_action_callback("remove_objective") do |web_dialog,msg|
                    obj = JSON.parse(msg)
                    workplane = obj["workplane"]
                    objective = obj["objective"]
                    
                    wps = Utilities.get_workplanes(Sketchup.active_model.entities)                                                            
                    wps = wps.select{|x| Labeler.get_name(x)==workplane}

                    workplane = wps[0]                                                    
                    value = Labeler.get_value(workplane)                    
                    value.delete(objective)
                    Labeler.set_value(workplane, value)  
                    script = ""                    
                    script += "workplanes = JSON.parse('#{self.get_workplanes_json}');"
                    script += "objectiveModule.update_objectives();"
                    web_dialog.execute_script(script)              
                end


                return wd
            end





        end
    end
end
                