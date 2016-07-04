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
                    wp_file = "./Workplanes/#{Utilities.fix_name(@target["workplane"])}.pts"
                    workplane = Utilities.fix_name(@target["workplane"])
                    nsensors = File.readlines(wp_file).length
                    script << "oconv ./Materials/materials.mat ./scene.rad ./Skies/#{sky}.rad ./Windows/windows.rad > octree.oct"
                    script << "rtrace -I+ -h -af ambient.amb #{options["rtrace"]} ./octree.oct < #{wp_file} > tmp1.tmp"
                    script << "rcollate -oc 1 -hi -or #{nsensors} -oc 1 ./tmp1.tmp > tmp2.tmp"                    
                    script << "rmtxop -fa -c 47.4 119.9 11.6 ./tmp2.tmp > tmp3.tmp"
                    script << "rcollate -oc 1 -ho  ./tmp3.tmp > ./Results/#{workplane}-#{sky}.txt"  
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
                    script << "rmtxop ./DC/#{workplane}.dc #{skyvecfile} > tmp1.tmp "
                    script << "rmtxop -fa -c 47.4 119.9 11.6 ./tmp1.tmp > tmp2.tmp "
                    script << "rcollate -oc 1 -ho ./tmp2.tmp > ./Results/#{workplane}-#{sky}.txt"                    
                    next script
                }

            end
        end




    end
end