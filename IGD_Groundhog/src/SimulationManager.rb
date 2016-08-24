module IGD
    module Groundhog
        
        # This class is the core of Groundhog simulation management. A SimulationManager
        # object will handle different Tasks, intending to reuse calculations as much as possible.
        # 
        # The idea was to create a sort of Make or Rake; defining requirements for each task
        class SimulationManager     

            # This method initializes the Simulation Manager
            # @author Germán Molina
            # @param options [Hash] The options sent from the WebDialog for the simulation
            def initialize(options)
                @options = options
                @tasks = []
                hash = DesignAssistant.get_workplanes_hash
                workplanes = hash["workplanes"]
                objectives=hash["objectives"]
                UI.messagebox "There are no workplanes to calculate" if workplanes.length == 0
                workplanes.each{|workplane,obj_array| 
                    # Add the calculation of artificial lighting                  
                    @tasks << ELux.new(workplane)
                    #then the daylighting objectives
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
           
            # Receives an objective and creates a task to be performed from it.
            # @param workplane [String] The name of the workplane to which the task is being created
            # @param objective [Hash] The objective from which the task will be assembled.
            # @author Germán Molina
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


            # Expands all the simulation manager tasks, obtaining their subtasks (requirements).
            # @author Germán Molina
            def expand!
                ret = []
                @tasks.each {|task|
                    ret = ret + task.expand
                }
                @tasks = ret                
            end

            # Removes the repeated tasks; keeping just the first one required.
            # That is, if calculating the Sky Contribution DC matrix over a workplane
            # is required twice, it will be done just once and the information generated
            # will be reused.
            # @author Germán Molina
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
              
            # This is meant to be called from the directory where the Radiance
            # model was exported
            # @author Germán Molina
            # @return [Array] An array of commands that, when run, will perform all the needed calculations
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


        # This class is the parent of all the pre-defined tasks (i.e. calculate DC matrix).
        # it contains basic methods that are common for every task.
        #
        # Every task contains a target, a proc and dependencies.
        #
        # The target is what makes it
        # unique when compared to other similar tasks (i.e. calculating the luminaire contribution
        # for one workplane is different from calculating the luminaire contribution to another
        # workplane).
        #
        # The proc is a Proc object that is run when solved. It is intended to return the necessary
        # commands that, when run, will accomplish such task (i.e. rfluxmtx -ab ...)
        #
        # The dependencies is an array with other Tasks that must be run before this task
        class Task            
           	
            attr_accessor :proc, :target, :dependencies

            # initialize.
            # @author Germán Molina
            def initialize
                @target = false
                @proc = false
                @dependencies = false                                     
            end                        

            # Solve a task is running its proc by using the options given to the
            # SimulationManager object that solves all tasks.
            # @param options [Hash] The options... usually a SimulationManager attribute
            # @return [Boolean] Success
            # @author Germán Molina
            def solve(options)
                success = @proc.call(options)
                warn "Fatal: Impossible to solve #{self}" if not success
                return false if not success                
                return success
            end

            # Expand a task means returning an array of itself (that task)
            # as well as all its dependencies and, recursively, its dependencies'
            # dependencies.
            # @return [Array] all the tasks
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
