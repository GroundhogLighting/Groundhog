module GH
    module Groundhog
        module DesignAssistant

            def self.load_tasks(wd)
                wd.add_action_callback('load_tasks'){|action_context,tasks|
                    Utilities.get_tasks_registry.each{|task|
                        Utilities.push_task_to_ui(task)
                    }
                }
            end # end of load_task

            def self.add_task(wd)
                wd.add_action_callback("add_task"){ |action_context,task|
                    task = JSON.parse(task)                    
                    Utilities.register_task(task)
                }
            end # End of and_task

            def self.remove_task(wd)
                wd.add_action_callback("remove_task"){ |action_context,task_name|                    
                    Utilities.unregister_task(r,false)
                }
            end # End of and_task

            def self.edit_task(wd)
                wd.add_action_callback("edit_task"){ |action_context,task|                    
                    # Parse the data
                    new_task = JSON.parse(task)
                    old_name = new_task['oldName']
                    new_name = new_task['name']
                    new_task.delete('oldName')                    
                    
                    # Change the values in the workplan's, if necessary
                    if old_name != new_name then
                        r = Utilities.get_workplanes_registry
                        r.each{|wp|
                            tasks = wp['tasks']
                            if tasks.include?(old_name) then
                                tasks.delete(old_name)
                                tasks.push(new_name)
                                
                                script = "workplanes.forEach(function(e){if(e.tasks.includes('#{old_name}')){ var t = e.tasks; var i = t.indexOf('#{old_name}');t.splice(i,1);t.push('#{new_name}') }})"                                
                                wd.execute_script(script)
                            end
                        }
                        Utilities.set_workplanes_registry(r)
                    end

                    # Change registry in dictionary                    
                    r = Utilities.get_tasks_registry
                    r.each_with_index{|t,i|                        
                        if t['name'] == old_name then
                            r[i] = new_task
                            break
                        end
                    }
                    
                    Utilities.set_tasks_registry(r)
                }
            end # End of edit_task

            def self.match_task_and_wp(wd)
                wd.add_action_callback("match_task_and_wp"){ |action_context,data|                    
                    data = JSON.parse(data)
                    wp_name = data['workplane']
                    task_name = data['task']

                    r = Utilities.get_workplanes_registry                    
                    r.each{|wp|
                        if wp['name'] == wp_name then
                            if wp['tasks'].include?(task_name) then
                                wp['tasks'].delete(task_name)
                            else
                                wp['tasks'].push(task_name)
                            end
                            Utilities.set_workplanes_registry(r)
                            break
                        end
                    }
                }
            end # End of edit_task


        end
    end
end