module GH
    module Groundhog
        module DesignAssistant

            def self.show_task_results(wd)
                wd.add_action_callback("show_task_results") do |action_context,task_name|

                    # remark
                    min_max = Results.remark_solved_workplanes(task_name)

                    # update scale
                    script = "scale.min=Math.floor(#{min_max[0]});scale.max=Math.ceil(#{min_max[1]});"                    
                    wd.execute_script(script)
                    
                end
            end # end of show_task_results function

            def self.load_results(wd)
                wd.add_action_callback("load_results") do |action_context,task_name|

                    results = Utilities.get_solved_workplanes.map{|x|
                        Labeler.get_value(x)
                    }
                    
                    script = []
                    results.each{|x|
                        script << "project_results.push(#{x})"
                    }

                    # update results
                    wd.execute_script("#{script.join(";")};")
                    
                end
            end # end of load_results function


            def self.update_scale(wd)
                wd.add_action_callback("update_scale") do |action_context,data|                    
                    data = JSON.parse(data)
                    min = data["min"]
                    max = data["max"]
                    metric_name = data["task"]

                    model = Sketchup.active_model
                    model.start_operation("change_scale",true)
                    Results.update_pixel_colors(min,max,metric_name)                    
                    model.commit_operation
                end
            end # end of update_scale function


        end
    end
end