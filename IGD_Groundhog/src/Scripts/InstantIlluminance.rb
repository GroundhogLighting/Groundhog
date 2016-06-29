module IGD
    module Groundhog        


        class RtraceActualIlluminance < Task
            def initialize(target) 
                #target is a Hash with the sky and the 
                #name of the workplane
                @target = target
                @dependencies = [WriteSky.new(target["sky"])]
                @proc = Proc.new {|options|
                    script = []
                    sky = Utilities.fix_name(@target["sky"])
                    workplane = "./Workplanes/#{Utilities.fix_name(@target["workplane"])}.pts"
                    script << "oconv ./Materials/materials.mat ./scene.rad ./Skies/#{sky}.rad Windows/windows.rad > octree.oct"
                    script << "rtrace -h -I+ -af ambient.amb -oov #{options["rtrace"]} octree.oct < #{workplane} > tmp1.tmp"
                    next script
                }

               
            end
        end




    end
end