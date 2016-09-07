module IGD
    module Groundhog

        class ELux < Task

            def initialize(workplane)
                @target = workplane #the workplane

                @proc = Proc.new { |options|                    
                    wp = Utilities.fix_name @target                                                       
                    wp_file="./Workplanes/#{wp}.pts"
                    nsensors = File.readlines(wp_file).length
                    
                    win_string = ""
                    win_string = "./Windows/windows.rad" if File.directory? "Windows" 

                    script = []                        
                    script << "#{OS.oconv_command( {:lights_on => true, :sky => false} )} > no_sky.oct"          
                    script << "rtrace -I+ -h -af no_sky.amb #{options["elux_ray_tracing_parameters"]} ./no_sky.oct < #{wp_file} > tmp1-#{wp}.tmp"
                    script << "rcollate -oc 1 -hi -or #{nsensors} -oc 1 ./tmp1-#{wp}.tmp > tmp2-#{wp}.tmp"                    
                    script << "rmtxop -fa -c 47.435 119.93 11.635 ./tmp2-#{wp}.tmp > tmp3-#{wp}.tmp"
                    script << "rcollate -oc 1 -ho  ./tmp3-#{wp}.tmp > ./Results/#{wp}-elux.txt" 
                    next script
                }

            end

        end



    end
end