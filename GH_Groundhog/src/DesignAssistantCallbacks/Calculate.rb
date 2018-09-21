module GH
    module Groundhog
        module DesignAssistant

            def self.set_option(wd)
                wd.add_action_callback('set_option') do |action_context,msg|
                    opt = JSON.parse(msg)
                    Sketchup.active_model.set_attribute(GROUNDHOG_DICTIONARY,opt['id'],opt['value'])                        

                end
            end # end of set_option function

            def self.set_various_options(wd)
                wd.add_action_callback('set_various_options') do |action_context,msg|
                    
                    # Get the options to set
                    current_options = JSON.parse(msg)

                    model = Sketchup.active_model
                    current_options.each{|opt|
                        model.set_attribute(GROUNDHOG_DICTIONARY,opt['id'],opt['value'])                        
                    }

                end
            end # end of set_various_options function

            def self.load_options(wd)
                wd.add_action_callback('load_options') do |action_context,msg|
                    
                    # Get the options to set
                    current_options = JSON.parse(msg)

                    script = ""

                    model = Sketchup.active_model
                    current_options.each{|opt|
                        v = model.get_attribute(GROUNDHOG_DICTIONARY,opt['id'])
                        if v then
                            opt['value'] = v
                            optname = opt["name"]
                            new_opt = "{ name: '#{optname}', id: '#{opt["id"]}', value: #{v}}"
                            script += "updateByName(project_options,#{new_opt});"
                        end
                    }
                    
                    wd.execute_script(script)
                end
            end # end of load_options function

            def self.run_emp_script(wd)
                wd.add_action_callback('run_emp_script') do |action_context,script_name|
                    OS.run_emp_script(script_name,true)
                end
            end

            def self.rvu(wd)
                wd.add_action_callback('rvu') do |action_context,script_name|
                    OS.run_emp_script("rvu",false)
                end
            end



        end # End module
    end # End module
end # End module