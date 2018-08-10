module GH
    module Groundhog
        module DesignAssistant

            def self.load_luminaires(wd)
                wd.add_action_callback('load_luminaires') do |action_context,msg|                    
                    script = ""
                    Sketchup.active_model.definitions.select{|x| 
                        Labeler.luminaire?(x)
                    }.each{|luminaire|
                        v = JSON.parse(Labeler.get_value(luminaire))
                        v.delete("ies")
                        script += "luminaires.push(#{v.to_json});"
                    }

                    wd.execute_script(script)
                    

                end
            end # end of set_option function

        end
    end
end