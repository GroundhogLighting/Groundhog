module IGD
    module Groundhog        


        class RtraceInstantIlluminance < Task
            def initialize(target) 
                #target is a Hash with the sky and the 
                #name of the workplane
                @target = target
                @dependencies = [WriteSky.new(@target["sky"])]
                @proc = Proc.new {|options|                    
                    script = []
                    sky = Utilities.fix_name(@target["sky"])
                    wp_file = "./Workplanes/#{Utilities.fix_name(@target["workplane"])}"
                    # check if it exist. If it does; go on... if it does not; test
                    # for instances
                    wps = []
                    if File.file? "#{wp_file}.pts" then
                        wps << wp_file
                    elsif File.file? "#{wp_file}_0.pts" then #check for the first instance
                        i=0
                        while File.file? "#{wp_file}_#{i}.pts" do                           
                            wps << "#{wp_file}_#{i}"                      
                            i+=1
                        end
                    else
                        next false #if it does not exist; cannot solve.
                    end

                    #Then, solve each instance.
                    wps.each{|wp|
                        workplane = Utilities.fix_name wp.split("/").pop
                        
                        wp_file="#{wp}.pts"
                        # workplane = Utilities.fix_name(@target["workplane"])
                        nsensors = File.readlines(wp_file).length
                        win_string = ""
                        win_string = "./Windows/windows.rad" if File.directory? "Windows" 
                        script << "oconv ./Materials/materials.mat ./scene.rad ./Skies/#{sky}.rad #{win_string} > octree-#{sky}.oct"
                        script << "rtrace -I+ -h -af ambient.amb #{options["ray_tracing_parameters"]} ./octree-#{sky}.oct < #{wp_file} > tmp1-#{sky}.tmp"
                        script << "rcollate -oc 1 -hi -or #{nsensors} -oc 1 ./tmp1-#{sky}.tmp > tmp2-#{sky}.tmp"                    
                        script << "rmtxop -fa -c 47.435 119.93 11.635 ./tmp2-#{sky}.tmp > tmp3-#{sky}.tmp"
                        script << "rcollate -oc 1 -ho  ./tmp3-#{sky}.tmp > ./Results/#{workplane}-#{sky}.txt"                          
                    }
                    
                    next script
                   
                }               
            end
        end

        class DCInstantIlluminance < Task
            def initialize(target)
                #target is a Hash with the sky and the 
                #name of the workplane
                @target = target
                workplane = target["workplane"]
                sky = target["sky"]
                @dependencies = [CalcDaylightCoefficients.new(workplane), GenSkyVec.new(sky)]
                @proc = Proc.new {|options|
                    script = []
                    workplane = Utilities.fix_name(@target["workplane"])
                    sky = Utilities.fix_name(@target["sky"])                    
                    skyvecfile ="./Skies/#{Utilities.fix_name(@target["sky"])}.skv"
                    script << "rmtxop ./DC/#{workplane}.dc #{skyvecfile} > tmp1-#{sky}.tmp "
                    script << "rmtxop -fa -c 47.435 119.93 11.635 ./tmp1-#{sky}.tmp > tmp2-#{sky}.tmp "
                    script << "rcollate -oc 1 -ho ./tmp2-#{sky}.tmp > ./Results/#{workplane}-#{sky}.txt"                    
                    next script
                }

            end
        end




    end
end