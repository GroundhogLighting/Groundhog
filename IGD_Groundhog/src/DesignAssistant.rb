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
        obj_hash = Objectives.get_objectives_hash
        wp_hash = JSON.parse Sketchup.active_model.get_attribute("Groundhog","workplanes")
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
        ret["LM-83 wall material"]={"rad" => "void plastic %MAT_NAME% 0 0 5 0.5 0.5 0.5 0 0", "color" => [127,127,127], "alpha" => 1, "name"=> "LM-83 wall material", "class" => "plastic"}
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
      # @return [Hash] the report
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

      # Search for workplanes in the model and assembles an object with the statistics of their electric lighting calculations
      # @author German Molina
      # @return [Hash] the report
      def self.get_elux_report
        report = Hash.new
        wps = IGD::Groundhog::Utilities.get_solved_workplanes(Sketchup.active_model.entities)
        wps.map{|x| Labeler.get_value(x)}.each{|val|
          value = JSON.parse(val)
          next if not "ELUX" == value["objective"]
          workplane = value["workplane"]
          report[workplane] = Hash.new if report[workplane] == nil
          report[workplane]["average"] = value["average"]
          report[workplane]["min_over_average"] = value["min_over_average"]
          report[workplane]["min_over_max"] = value["min_over_max"]
          report[workplane]["min"] = value["min"]
          report[workplane]["max"] = value["max"]
        }
        return report
      end

      # This is the action performed when selecting a goal to be shown.
      # It "remkars" the workplanes corresponding to that goal, and updates
      # the scale in the Report section of WebDialog
      # @author German Molina
      # @return [String] The script that modifies the scale
      def self.select_objective(objective)
        return "$('#compliance_summary_scale_max').text('--');$('#elux_compliance_scale_max').text('--');$('#luminaire_scale_max').text('--');" if objective == nil
        Utilities.remark_solved_workplanes(objective)
        min_max = Results.get_min_max_from_model(objective)
        max=min_max[1]
        script = ""
        if objective=="ELUX" then
          script += "$('#elux_compliance_scale_max').text('#{max.round}');"
          script += "$('#luminaire_scale_max').text('#{max.round}');"
          script += "$('#compliance_summary_scale_max').text('--');"
        else
          script += "$('#elux_compliance_scale_max').text('--');"
          script += "$('#luminaire_scale_max').text('--');"
          script += "$('#compliance_summary_scale_max').text('#{max.round}');"
        end
        script += "DesignAssistant.report.highlight_objective('#{objective}');"
        return script
      end

      # Updates the Design Assistant to the actual state of the model... this is called
      # when the dialog is opened and also, for example, when the user defines a new
      # workplane.
      # @author German Molina
      def self.update

        wd = IGD::Groundhog.design_assistant
        return if not wd.visible?

        hash = self.get_workplanes_hash
        workplanes = hash["workplanes"].to_json
        objectives = hash["objectives"].to_json
        materials = self.get_radiance_materials_hash.to_json

        script = ""
        
        script += "DesignAssistant.materials.materials = #{materials};"    
        script += "DesignAssistant.materials.updateList('');"

        script += "DesignAssistant.objectives.workplanes = #{workplanes};"        
        script += "DesignAssistant.objectives.objectives = #{objectives};"
        script += "DesignAssistant.objectives.update_workplanes('');"
        script += "DesignAssistant.objectives.update_objectives('');"

        weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
        
        if weather != nil then
            weather = JSON.parse(weather)
            weather.delete "data"
            weather = weather.to_json 
            script += "DesignAssistant.location.setWeatherData(#{weather});"           
        end

        report = self.get_actual_report
        script += "DesignAssistant.report.results = #{report.to_json};"
        script += "DesignAssistant.report.update_compliance_summary();"
        script += "DesignAssistant.report.update_objective_summary();"
        script += "DesignAssistant.report.elux_results = #{self.get_elux_report.to_json};"
        script += "DesignAssistant.report.update_elux_compliance_summary();"

        #update luminaire list
        luminaires = self.get_luminaires_hash.to_json
        script += "DesignAssistant.luminaires.luminaires = #{luminaires};"
        script += "DesignAssistant.luminaires.updateList('');"

        #remark the first objective
        objective = hash["objectives"].keys.shift
        script += self.select_objective(objective)

        #execute
        wd.execute_script(script)
      end

      # Returns the Design Assistant.
      #
      # @author German Molina
      # @return [SketchUp::UI::WebDialog] the Design Assistant web dialog
      def self.get
        wd = Utilities.build_web_dialog("Design Assistant",false,"DAsistant",500,500,true,"#{OS.main_groundhog_path}/src/html/design_assistant.html")

        wd.add_action_callback("on_load") do |action_context,msg|          
          self.update
        end

        wd.add_action_callback("set_weather_path") do |action_context,msg|
          path = self.ask_for_weather_file
          self.set_weather(path)
          weather = Sketchup.active_model.get_attribute("Groundhog","Weather")
          if weather != nil then
            weather = JSON.parse(weather)
            weather.delete "data"
            weather = weather.to_json 
            script = "DesignAssistant.location.setWeatherData(#{weather})"
            wd.execute_script(script)
          end
        end

        wd.add_action_callback("follow_link") do |action_context,msg|
          UI.openURL(msg)
        end

        wd.add_action_callback("preview") do |action_context,msg|
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
            script << "#{OS.oconv_command( {:lights_on => true, :sky => "sky"} )} > octree.oct"
            #script << "oconv ./Materials/materials.mat ./scene.rad  ./Skies/sky.rad  #{win_string}  > octree.oct"
            script << "rvu #{Config.rvu_options} -vf Views/view.vf octree.oct"
            OS.execute_script(script)
            OS.clear_actual_path
          end
        end

        wd.add_action_callback("night_preview") do |action_context,msg|
          path = "#{Sketchup.temp_dir}/Groundhog"
          OS.mkdir(path)
          if not Exporter.export(path) then
            UI.messagebox "Error while exporting... Sorry! Contact us to gmolina@igd.cl if the problem persists."
            next
          end

          FileUtils.cd(path) do
            script=[]
            script << "#{OS.oconv_command( {:lights_on => true, :sky => false} )} > no_sky.oct"
            #script << "oconv ./Materials/materials.mat ./scene.rad #{win_string}  > octree.oct"
            script << "rvu #{Config.rvu_options} -vf Views/view.vf no_sky.oct"
            OS.execute_script(script)
            OS.clear_actual_path
          end
        end

        wd.add_action_callback("use_material") do |action_context,msg|
          materials = Sketchup.active_model.materials
          m = JSON.parse(msg)
          name = m["name"]
          if materials[name] == nil then #add it if it does not exist
            Materials.add_material(m)
          end
          Sketchup.send_action("selectPaintTool:")
          materials.current=materials[name]
        end

        wd.add_action_callback("add_material") do |action_context,msg|
          m = JSON.parse(msg)
          Materials.add_material(m)
        end



        wd.add_action_callback("use_luminaire") do |action_context,msg|
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




        wd.add_action_callback("remove_material") do |action_context,name|
          materials = Sketchup.active_model.materials
          materials.remove(materials[name]) if materials[name] != nil
        end

        wd.add_action_callback("add_objective") do |action_context,msg|
          obj = JSON.parse(msg)
          wp_name = obj["workplane"]
          objective_name = obj["objective"]
          Objectives.add_objective_to_workplane(wp_name,objective_name)
        end

        wd.add_action_callback("create_objective") do |action_context,msg|
          objective = JSON.parse(msg)
          Objectives.create_objective(objective)
        end

        wd.add_action_callback("delete_objective") do |action_context,msg|
          name = msg
          Objectives.delete_objective(name)

          #update design assistant.
          hash = self.get_workplanes_hash
          workplanes = hash["workplanes"].to_json
          objectives = hash["objectives"].to_json
          script = ""
          script += "ObjectivesModule.workplanes = JSON.parse('#{workplanes}');"
          script += "ObjectivesModule.objectives = JSON.parse('#{objectives}');"
          script += "ObjectivesModule.update_workplanes('');"
          script += "ObjectivesModule.update_objectives('');"
          wd.execute_script(script)
        end


        wd.add_action_callback("remove_objective") do |action_context,msg|
          obj = JSON.parse(msg)
          workplane = obj["workplane"]
          objective_name = obj["objective"]
          Objectives.remove_objective_from_workplane(workplane,objective_name)

          #update design assistant.
          hash = self.get_workplanes_hash
          workplanes = hash["workplanes"].to_json
          script = ""
          script += "workplanes = JSON.parse('#{workplanes}');"
          script += "objectiveModule.update_workplanes('');"
          wd.execute_script(script)
        end

        wd.add_action_callback("remark") do |action_context, objective|
          wd.execute_script self.select_objective(objective)
        end


        wd.add_action_callback("calculate") do |action_context, options|
          path = "#{Sketchup.temp_dir}/Groundhog"
          OS.mkdir(path)
          next if not Exporter.export(path)
          FileUtils.cd(path) do
            options = JSON.parse(options)

            #Pre-process information
            sim = SimulationManager.new(options)
            next if not sim
            script = sim.solve #this includes Electric Lighting Calculations

            #Process data
            next if not OS.execute_script(script)

            # post-process and load results
            # Lets start by Daylighting
            report = self.get_actual_report

            hash = self.get_workplanes_hash
            workplanes = hash["workplanes"]
            objectives=hash["objectives"]

            workplanes.each{|workplane,obj_array|
              #initialize the object where the information to report will be stored
              report[workplane]=Hash.new
              pixel_file = "./Workplanes/#{Utilities.fix_name(workplane)}.pxl"
              #then go through the objectives
              obj_array.each{|obj_name|
                objective = objectives[obj_name]
                warn objective
                metric = objective["metric"]
                file_to_read = Metrics.get_read_file(metric)
                file_to_read = file_to_read.call(workplane,objective) if file_to_read != false
                file_to_write = Metrics.get_write_file(metric).call(workplane,objective)
                score_calculator = Metrics.get_score_calculator(metric)

                if objective["dynamic"] then
                  annual = File.readlines(file_to_read)
                  #remove header
                  7.times {annual.shift}

                  early = objective["occupied"]["min"]
                  late = objective["occupied"]["max"]
                  month_ini = 1
                  month_end = 12

                  results = []
                  annual.each{|sensor_data|
                    data = sensor_data.split(" ").map{|x| x.to_f}
                    sensor_working_hours = data.each_with_index.select{|val, index|
                      hour = (index+0.5)%24
                      hour >= early and hour <= late
                    }.map{|value,index| value}
                    results << score_calculator.call(workplane,objective,sensor_working_hours)
                  }
                  File.open(file_to_write,'w'){ |f| f.puts results }
                else
                  if score_calculator != false then
                    results = File.readlines(file_to_read).map{|x| x.to_f}
                    File.open(file_to_write,'w'){ |f| f.puts results.map{|x| score_calculator.call(x)} }
                  end
                end
                report[workplane][obj_name]=Results.import_results(file_to_write,pixel_file,workplane,objective)

              }
            }

            objectives.each{|obj_name, value|
              min_max=Results.get_min_max_from_model(obj_name)
              Results.update_pixel_colors(0,min_max[1],value)	#minimum is 0 by default 
            }
            # Then import electric lighting results
            if Config.calc_elux then
              #Import results
              objective = {   "name" => "ELUX",
                "good_light" => {"min" => 0, "max" => 9e19},
                "dynamic" => false
              }


              workplanes.each{|workplane,obj_array|
                wp = Utilities.fix_name workplane
                results = "./Results/#{wp}-elux.txt"
                pixel_file = "./Workplanes/#{wp}.pxl"
                Results.import_results(results,pixel_file,workplane,objective)
              }

              #Update colors
              min_max=Results.get_min_max_from_model("ELUX")
              Results.update_pixel_colors(0,min_max[1],objective)	#minimum is 0 by default
            end



            script = ""
            script += "results = JSON.parse('#{report.to_json}');"
            script += "DesignAssistant.report.update_compliance_summary();"
            script += "elux_results = JSON.parse('#{self.get_elux_report.to_json}');"
            script += "DesignAssistant.report.update_elux_compliance_summary();"

            #remark first objective
            script += self.select_objective("ELUX") if Config.calc_elux
            script += self.select_objective(objectives.keys.shift) if not Config.calc_elux

            wd.execute_script(script)
          end

        end


        return wd
      end




    end
  end
end
