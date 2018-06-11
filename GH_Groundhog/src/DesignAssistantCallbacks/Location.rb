module GH
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
            end # end of ask_for_weather_file
    
            # Opens, reads and parses a weather file. The file gets registered into the model
            # @author German Molina
            # @param path [String] the path to the weather file
            # @return the weather information if success, false if not
            def self.set_weather(path)
                return false if not path
    
                # Check if the model already is georeferenced, and warn
                if Sketchup.active_model.georeferenced? then
                result = UI.messagebox('This model is already georeferenced. Choosing a weather file will replace this location. Do you want to continue?', MB_YESNO)
                return false if result == IDNO
                end
    
                # Read the weather
                weather = Weather.parse_epw(path)
    
                # Add it to the model
                Sketchup.active_model.set_attribute(GROUNDHOG_DICTIONARY,WEATHER_KEY,weather.to_json)
    
                weather.delete "data"
    
                # Modify model
                shadow_info = Sketchup.active_model.shadow_info
                shadow_info["City"]=weather["city"]
                shadow_info["Country"] = weather["country"]
                shadow_info["Latitude"] = weather["latitude"]
                shadow_info["Longitude"] = weather["longitude"]
                shadow_info["TZOffset"] = weather["timezone"]
        
                return weather
            end # end set_weather

            def self.set_weather_file(wd)
                wd.add_action_callback("set_weather_file") do |action_context,msg|

                    # Ask for a file
                    path = self.ask_for_weather_file

                    # Return if dialog is closed.            
                    next if not path 

                    # Add the 
                    weather_info = self.set_weather(path)
                    
                    if weather_info then
                
                        w = weather_info 
                        #script = "project_location = JSON.parse('#{w.to_json}')"
                        
                        script = ""
                        w.each{|key,value|
                            script += "project_location['#{key}'] = '#{value}';"
                        }

                        script+="has_weather_file = true;"
                        
                        GH::Groundhog.design_assistant.execute_script(script)
                    end
                end
            end # end of set_weather_file function

            
            def self.update_model_location(wd)
                wd.add_action_callback('update_model_location') do |action_context,msg|
                    UI::messagebox('Test!')
                end
            end # end of update_model_location function

        end # End module DesigAssistant
    end # End module Groundhog
end # End module GH
