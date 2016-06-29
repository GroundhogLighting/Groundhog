module IGD
    module Groundhog
        
         
        class SimulationManager
            attr_accessor :tasks

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

            def show
                warn @tasks
            end      

            def solve(options)
                path="Radiance Model" #Sketchup.temp_dir
                ret = []
                FileUtils.cd(path) do
                    self.expand!
                    self.uniq!                    
                    @tasks.each{|task|
                        ret = ret + task.solve(options)
                    }
                end
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
            
            def solvable?
                return true if not @dependencies                
                @dependencies.each{|x|                    
                    return false if not x.solvable?
                }
                return true
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
