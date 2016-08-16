module IGD
    module Groundhog

        # This module is the one that creates and has all the methods within the Design Assistant; the main
        # Groundhog UI.		
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
					result = UI.messagebox('This model is already georeferenced. Choosing a weather file will replace this location. Do you want to continue?', MB_YESNO)
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

            # Search for workplanes in the model and find their objectives. Returns a Hash
            # with the corresponding format.
			# @author German Molina			
			# @return [Hash] the workplanes and objectives            
            def self.get_workplanes_hash
                
                workplanes = Utilities.get_workplanes(Sketchup.active_model.entities) 

                wp_hash = Hash.new
                obj_hash = Hash.new                
                workplanes.each { |wp|
                    value = Labeler.get_value(wp)
                    if value == nil or not value then
                        wp_hash[Labeler.get_name(wp)] = []
                    else
                        value = JSON.parse(value)  #this should  be an array of Hash
                        value.each {|objective|
                            obj_hash[objective["name"]] = objective #does not requie "uniq"
                        }                               
                        aux = []    
                        value.each{|x| aux << x["name"]}                          
                        wp_hash[Labeler.get_name(wp)] = aux.uniq
                    end                    
                }                
                return {"workplanes" => wp_hash, "objectives" => obj_hash}
            end

            # Search for the luminaire definition
			# @author German Molina			
			# @return [Hash] the luminaires         
            def self.get_luminaires_hash
                ret = Hash.new
                
                luminaires = Sketchup.active_model.definitions.select{|x| Labeler.luminaire? x }
                luminaires.each{|x|
                    # Get the data if needed.
                    data = JSON.parse(Labeler.get_value(x))
                    data.delete("ies")                    
                    ret[data["luminaire"]]=data
                }


                return ret
            end

            # Search for materials that have Radiance definition
			# @author German Molina			
			# @return [Hash] the materials         
            def self.get_radiance_materials_hash
                ret = Hash.new
                mats = Sketchup.active_model.materials.select{|x| Labeler.rad_material? x}

                mats.each{|x| 
                    info = JSON.parse IGD::Groundhog::Labeler.get_value x
                    ret[x.name] = info
                }        

                #insert (or replace) defaults from LM-83
                ret["LM-83 floor material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.2 0.2 0.2 0 0", "color" => [51,51,51], "alpha" => 1, "name"=> "LM-83 floor material", "class" => "plastic"}
                ret["LM-83 wall material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.5 0.5 0.5 0 0", "color" => [127,127,127], "alpha" => 1, "name"=> "LM-83 wall material ", "class" => "plastic"}
                ret["LM-83 ceiling material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.7 0.7 0.7 0 0", "color" => [178,178,178], "alpha" => 1, "name"=> "LM-83 ceiling material", "class" => "plastic"}
                ret["LM-83 furniture material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.5 0.5 0.5 0 0", "color" => [127,127,127], "alpha" => 1, "name"=> "LM-83 furniture material", "class" => "plastic"}
                ret["LM-83 tree material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.2 0.2 0.2 0 0", "color" => [104, 178, 38], "alpha" => 1, "name"=> "LM-83 tree material", "class" => "plastic"}
                ret["LM-83 ground material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.1 0.1 0.1 0 0", "color" => [25,25,25], "alpha" => 1, "name"=> "LM-83 ground material", "class" => "plastic"}
                ret["LM-83 obstruction material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.3 0.3 0.3 0 0", "color" => [77,77,77], "alpha" => 1, "name"=> "LM-83 obstruction material", "class" => "plastic"}
                default_glass = Materials.default_glass
                ret[default_glass["name"]]=default_glass
                default_material = Materials.default_material
                ret[default_material["name"]]=default_material
                
                return ret
            end

            # Search for workplanes in the model and finds out weather they fulfil their
            # goals or not.
			# @author German Molina			
			# @return [Hash] the report# @todo Allow it gathering workplanes inside groups and components
            def self.get_actual_report
                report = Hash.new
                wps = Utilities.get_solved_workplanes(Sketchup.active_model.entities)
                wps.map{|x| Labeler.get_value(x)}.each{|val|
                    value = JSON.parse(val)
                    workplane = value["workplane"]
                    objective = value["objective"]
                    report[workplane] = Hash.new if report[workplane] == nil 
                    report[workplane][objective] = value["approved_percentage"]
                }
                return report
            end

            # This is the action performed when selecting a goal to be shown.
            # It "remkars" the workplanes corresponding to that goal, and updates
            # the scale in the Report section of WebDialog
			# @author German Molina			
			# @return [String] The script that modifies the scale
            def self.select_objective(objective)
                return "$('#compliance_summary_scale_max').text('--');" if objective == nil
                Utilities.remark_solved_workplanes(objective)
                min_max = Results.get_min_max_from_model(objective)
                max=min_max[1]
                script = "$('#compliance_summary_scale_max').text('#{max.round}');"                
                script += "reportModule.highlight_objective('#{objective}');"                
                return script
            end

            # Updates the Design Assistant to the actual state of the model... this is called
            # when the dialog is opened and also, for example, when the user defines a new
            # workplane.        
			# @author German Molina	
            def self.update
                web_dialog = IGD::Groundhog.design_assistant
                return if not web_dialog.visible?

                hash = self.get_workplanes_hash                    
                workplanes = hash["workplanes"].to_json                                         
                objectives = hash["objectives"].to_json                
                materials = self.get_radiance_materials_hash.to_json
                script = ""
                script += "materials = JSON.parse('#{materials}');"  
                script += "materialModule.update_list('');"                
                script += "workplanes = JSON.parse('#{workplanes}');" 
                script += "objectives = JSON.parse('#{objectives}');"                       
                script += "objectiveModule.update_workplanes('');" 
                script += "objectiveModule.update_objectives('');"                                               

                weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
                if weather != nil then
                    weather = JSON.parse(weather)
                    script += "document.getElementById('weather_city').innerHTML='#{weather["city"]}';"
                    script += "document.getElementById('weather_state').innerHTML='#{weather["state"]}';"
                    script += "document.getElementById('weather_country').innerHTML='#{weather["country"]}';"
                    script += "document.getElementById('weather_latitude').innerHTML='#{weather["latitude"]}';"
                    script += "document.getElementById('weather_longitude').innerHTML='#{weather["longitude"]}';"
                    script += "document.getElementById('weather_timezone').innerHTML='GMT #{weather["timezone"]}';"                        
                end
                
                report = self.get_actual_report
                script += "results = JSON.parse('#{report.to_json}');"        
                script += "reportModule.update_compliance_summary();" 
                script += "reportModule.update_objective_summary();"                                                     

                #update luminaire list
                luminaires = self.get_luminaires_hash.to_json
                script += "luminaires = JSON.parse('#{luminaires}');"  
                script += "luminaireModule.update_list('');"

                #remark the first objective
                objective = hash["objectives"].keys.shift                    
                script += self.select_objective(objective) 
                
                #execute
                web_dialog.execute_script(script)                 
            end

            # Returns the Design Assistant.
			#
			# @author German Molina
			# @return [SketchUp::UI::WebDialog] the Design Assistant web dialog
            def self.get
                wd = UI::WebDialog.new("Design Assistant",false,"DAsistant",500,500,130,120,true)
		        wd.set_file("#{OS.main_groundhog_path}/src/html/design_assistant.html" )                

                wd.add_action_callback("on_load") do |web_dialog,msg|
                    self.update
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

                wd.add_action_callback("follow_link") do |web_dialog,msg|
                    UI.openURL(msg)
                end

                wd.add_action_callback("preview") do |web_dialog,msg| 
                    path = "#{Sketchup.temp_dir}/Groundhog"
                    OS.mkdir(path)

                    if not Exporter.export(path) then
                        UI.messagebox "Error while exporting... Sorry! Contact us to gmolina@igd.cl if the problem persists."
                        next
                    end                                   
                                        
                    FileUtils.cd(path) do   
                        script=[]     
                        win_string = ""
                        win_string = "./Windows/windows.rad" if File.directory? "Windows"      
                        script << "oconv ./Materials/materials.mat ./scene.rad  ./Skies/sky.rad  #{win_string}  > octree.oct"
                        script << "rvu #{Config.rvu_options} -vf Views/view.vf octree.oct"
                        OS.execute_script(script)
						OS.clear_actual_path
                    end                                       
                end

                wd.add_action_callback("night_preview") do |web_dialog,msg| 
                    path = "#{Sketchup.temp_dir}/Groundhog"
                    OS.mkdir(path)

                    if not Exporter.export(path) then
                        UI.messagebox "Error while exporting... Sorry! Contact us to gmolina@igd.cl if the problem persists."
                        next
                    end                                   
                                        
                    FileUtils.cd(path) do   
                        script=[]     
                        win_string = ""
                        win_string = "./Windows/windows.rad" if File.directory? "Windows"      
                        script << "oconv ./Materials/materials.mat ./scene.rad #{win_string}  > octree.oct"
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
                        hash = self.get_workplanes_hash
                        workplanes = hash["workplanes"].to_json                       
                        script = ""                    
                        script += "workplanes = JSON.parse('#{workplanes}');"                        
                        script += "objectiveModule.update_workplanes();"  
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



                wd.add_action_callback("use_luminaire") do |web_dialog,msg|
                    model = Sketchup.active_model
                    entities = model.entities
                    definitions = model.definitions

                    m = JSON.parse(msg)                   
                    name = m["name"]
                    luminaires = definitions.select{|x| IGD::Groundhog::Labeler.luminaire? x}                    
                    definition = luminaires.select{|x| JSON.parse(IGD::Groundhog::Labeler.get_value(x))["luminaire"] == name }
                                      
                    if definition.length == 0 then #it does not exist....
                        #In the future; load it.
                        UI.messagebox "Sorry, there was an error... there seem to be no luminare named '#{name}'"
                        next
                    elsif definition.length > 1 then
                        UI.messagebox "The luminare named '#{name}' seem to be defined at least twice... we will load the first definition of it."                        
                    end                    

                    entities.add_instance(definition[0],Geom::Transformation.new) 
                end




                wd.add_action_callback("remove_material") do |web_dialog,name|
                    materials = Sketchup.active_model.materials                                                                             
                    materials.remove(materials[name]) if materials[name] != nil
                end

                wd.add_action_callback("add_objective") do |web_dialog,msg|
                    obj = JSON.parse(msg)
                    wp_name = obj["workplane"]
                    objective = obj["objective"]
                    
                    wp = Utilities.get_workplanes(Sketchup.active_model.entities).select{|x| Labeler.get_name(x)==wp_name}                                        
                    wp=wp[0]
                    value = Labeler.get_value(wp)
                    value = "[]" if value == nil or not value
                    value = JSON.parse(value)
                    value << objective                    
                    Labeler.set_value(wp,value.to_json)
                                        
                end

                wd.add_action_callback("remove_objective") do |web_dialog,msg|
                    obj = JSON.parse(msg)
                    workplane = obj["workplane"]
                    objective = obj["objective"]    

                    wps = Utilities.get_workplanes(Sketchup.active_model.entities)                                                           
                    wps = wps.select{|x| Labeler.get_name(x)==workplane}
                    workplane = wps[0]   
                    #delete the objective from the workplane value                                                 
                    value = JSON.parse Labeler.get_value(workplane)   #this is an array of hash
                    del = value.select{|x| x["name"]==objective}
                    value.delete(del.shift) #delete the first one.
                    Labeler.set_value(workplane, value.to_json) 

                    #delete the solved workplane if it exist.                   
					IGD::Groundhog::Utilities.get_solved_workplanes(Sketchup.active_model.entities).select{|x|
						JSON.parse(IGD::Groundhog::Labeler.get_value(x))["objective"]==obj["objective"]
					}.select {|x|
						JSON.parse(IGD::Groundhog::Labeler.get_value(x))["workplane"]==obj["workplane"]
					}.each{|x|
						x.erase!
					}

                    #update design assistant.
                    hash = self.get_workplanes_hash
                    workplanes = hash["workplanes"].to_json                       
                    script = ""                    
                    script += "workplanes = JSON.parse('#{workplanes}');"                        
                    script += "objectiveModule.update_workplanes('');"  
                    web_dialog.execute_script(script)                                                   
                end

                wd.add_action_callback("remark") do |web_dialog, objective|                                                                             
                    web_dialog.execute_script self.select_objective(objective)
                end


                wd.add_action_callback("calculate") do |web_dialog, options|
                    path = "#{Sketchup.temp_dir}/Groundhog"
                    OS.mkdir(path)
                    next if not Exporter.export(path)
					FileUtils.cd(path) do
                        options = JSON.parse(options)
                        
                        #Pre-process information
                        sim = SimulationManager.new(options) 
                        next if not sim                       
                        script = sim.solve

                        #Process data                                                                      
                        next if not OS.execute_script(script)

                        #post-process and load results
                        report = Hash.new
                        all_objectives = []

                        hash = self.get_workplanes_hash
                        workplanes = hash["workplanes"]
                        objectives=hash["objectives"]

                        workplanes.each{|workplane,obj_array|
                            #initialize the object where the information to report will be stored
                            report[workplane]=Hash.new 

                            #then go through the objectives
                            obj_array.each{|obj_name|
                                all_objectives << obj_name
                                objective = objectives[obj_name]
                                pixel_file = "./Workplanes/#{Utilities.fix_name(workplane)}.pxl"
                                min_lux = objective["good_light"]["min"]
                                max_lux = objective["good_light"]["max"]

                                if objective["dynamic"] then
                                    path = "./Results/#{Utilities.fix_name(workplane)}-daylight.annual"
                                    early = objective["occupied"]["min"]
                                    late = objective["occupied"]["max"]                                    
                                    month_ini = 1
                                    month_end = 12

                                    results = "./Results/#{Utilities.fix_name(workplane)}-#{objective["name"]}.txt"
                                    File.open(results,'w'){ |f|
                                        f.puts Results.annual_to_udi(path,min_lux, max_lux, early,late,month_ini, month_end)
                                    }                                     
                                else                                    
                                    sky = "gensky -ang 45 40 -c -B 0.5586592 -g #{Config.albedo}"
                                    if objective["metric"] == "LUX" then
                                        date = Date.strptime(objective["date"], '%m/%d/%Y')
                                        month = date.month
                                        day = date.day
                                        hour = objective["hour"]
                                        lat = Sketchup.active_model.shadow_info["Latitude"]
                                        lon = -Sketchup.active_model.shadow_info["Longitude"]
                                        mer = -Sketchup.active_model.shadow_info["TZOffset"]
                                        sky = "gensky #{month} #{day} #{hour} -a #{lat} -o #{lon} -m #{15*mer} -g #{Config.albedo} +s"                        
                                    end
                                    results = "./Results/#{Utilities.fix_name(workplane)}-#{Utilities.fix_name(sky)}.txt"                                                                        
                                end                               
                                report[workplane][obj_name]=Results.import_results(results,pixel_file,workplane,objective)
                            }
                         }

                        objectives.each{|obj_name, value|
                            min_max=Results.get_min_max_from_model(obj_name)
                            Results.update_pixel_colors(0,min_max[1],value)	#minimum is 0 by default                            
                        }  
                         
                        script = ""
                        script += "results = JSON.parse('#{report.to_json}');"        
                        script += "reportModule.update_compliance_summary();"

                        #remark first objective
                        objective = objectives.keys.shift
                        script += self.select_objective(objective)

                        web_dialog.execute_script(script)   
                    end
                    
                end


                return wd
            end

            


        end
    end
end
                