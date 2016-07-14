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

            # Search for workplanes in the model and find their objectives. Returns an array
            # with the corresponding format.
			# @author German Molina			
			# @return [Hash] the workplanes and objectives
            # @todo Allow it gathering workplanes inside groups and components
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

            # Search for workplanes in the model and finds out weather they fulfil their
            # goals or not.
			# @author German Molina			
			# @return [Hash] the report
            # @todo Allow it gathering workplanes inside groups and components
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

            # Returns the Design Assistant.
			#
			# @author German Molina
			# @return [SketchUp::UI::WebDialog] the Design Assistant web dialog
            def self.get
                wd = UI::WebDialog.new("Design Assistant",false,"DAsistant",500,500,130,120,true)
		        wd.set_file("#{OS.main_groundhog_path}/src/html/design_assistant.html" )                

                wd.add_action_callback("on_load") do |web_dialog,msg|
                    hash = self.get_workplanes_hash                    
                    workplanes = hash["workplanes"].to_json                                         
                    objectives = hash["objectives"].to_json
                    script = ""                    
                    script += "workplanes = JSON.parse('#{workplanes}');" 
                    script += "objectives = JSON.parse('#{objectives}');"                       
                    script += "objectiveModule.update_workplanes();" 
                    script += "objectiveModule.update_objectives();"  
                                                       
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

                wd.add_action_callback("follow_link") do |web_dialog,msg|
                    UI.openURL(msg)
                end

                wd.add_action_callback("preview") do |web_dialog,msg| 
                    path = "#{Sketchup.temp_dir}/Groundhog"
                    OS.mkdir(path)

                    if not Exporter.export(path) then
                        UI.messagebox "Error while exporting... Sorry! Contact us to gmolina@igd.cl if the problem persists."
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
                    script += "objectiveModule.update_workplanes();"  
                    web_dialog.execute_script(script)                                                   
                end

                wd.add_action_callback("remark") do |web_dialog, objective|                                     
                    Utilities.remark_solved_workplanes(objective)
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
                        OS.execute_script(script)

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
                            Utilities.remark_solved_workplanes(obj_name)
                        }  
                         
                         script = ""
                         script += "results = JSON.parse('#{report.to_json}');"        
                         script += "reportModule.update_compliance_summary();"
                         web_dialog.execute_script(script)   
                    end
                    
                end


                return wd
            end

            


        end
    end
end
                