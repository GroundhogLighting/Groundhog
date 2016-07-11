module IGD
    module Groundhog
        
         
        class SimulationManager           
            def initialize(options)
                @options = options
                @tasks = []
                hash = DesignAssistant.get_workplanes_hash
                workplanes = hash["workplanes"]
                objectives=hash["objectives"]
                workplanes.each{|workplane,obj_array|
                    obj_array.each{|obj_name|
                        objective = objectives[obj_name]
                        task = self.get_task(workplane,objective)
                        if not task then
                            UI.messagebox("Error at workplane '#{workplane}' - objective '#{obj_name}' while building the Simulation Manager.")
                            return false
                        end
                        @tasks << task
                    }                    
                }

            end
           

            def get_task(workplane,objective)                                             
                task = false
                albedo = Config.albedo
                if objective["dynamic"] then
                    task = DCAnnualIlluminance.new(workplane)
                else
                    sky = "gensky -ang 45 40 -c -B 0.5586592 -g #{albedo}"
                    if objective["metric"] == "LUX" then
                        date = Date.strptime(objective["date"], '%m/%d/%Y')
                        month = date.month
                        day = date.day
                        hour = objective["hour"]
                        lat = Sketchup.active_model.shadow_info["Latitude"]
                        lon = -Sketchup.active_model.shadow_info["Longitude"]
                        mer = -Sketchup.active_model.shadow_info["TZOffset"]
                        sky = "gensky #{month} #{day} #{hour} -a #{lat} -o #{lon} -m #{15*mer} -g #{albedo} +s"                        
                    end
                    target = {"workplane" =>workplane, "sky" => sky}
                    case @options["static_calculation_method"] 
                    when "RTRACE"                        
                        task = RtraceInstantIlluminance.new(target)
                    when "DC"
                        task = DCInstantIlluminance.new(target)
                    else
                        return false
                    end 
                end

                return task
            end



            def expand!
                ret = []
                @tasks.each {|task|
                    ret = ret + task.expand
                }
                @tasks = ret                
            end

            def uniq!                                               
                ret = []
                @tasks.reverse_each {|task|                                   
                    cl = task.class         
                    sel = ret.select{|x| x.class == cl and x.target == task.target}    
                    next if sel.length > 0 #already there
                    ret << task            
                }
                @tasks =  ret
            end
              
            #This is meant to be called from the directory where the Radiance
            # model was exported
            def solve                
                ret = [] 
                OS.mkdir("DC")
                OS.mkdir("Results")               
                self.expand!
                self.uniq!                    
                @tasks.each{|task|
                    new_tasks = task.solve(@options)
                    ret = ret + new_tasks if new_tasks
                    return false if not new_tasks
                }
            
                return ret
            end     
        end



        class Task            
           	
            attr_accessor :proc, :target, :dependencies

            def initialize
                @target = false
                @proc = false
                @dependencies = false                                     
            end                        

            def solve(options)
                success = @proc.call(options)
                warn "Fatal: Impossible to solve #{self}" if not success
                return false if not success                
                return success
            end

            def expand
                if !@dependencies or @dependencies.length == 0 then                
                    return [self]
                else
                    ret = [self]
                    @dependencies.each {|dep|
                        ret = ret + dep.expand
                    }                   
                    return ret
                end
            end

        end

   


    end
end
