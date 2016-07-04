module IGD
    module Groundhog        


     
        class DCAnnualIlluminance < Task
            def initialize(workplane)               
                @target = workplane
                
                
                @dependencies = [CalcDaylightCoefficients.new(@target), GenDayMtx.new]
                
                @proc = Proc.new {|options|
                    script = []
                    workplane = Utilities.fix_name(@target)

                    script << "rmtxop ./DC/#{workplane}.dc ./Skies/weather.daymtx > tmp1.tmp"
                    script << "rmtxop -fa -c 47.4 119.9 11.6 ./tmp1.tmp > ./Results/#{workplane}-daylight.annual "                    

                    next script
                }

            end
        end




    end
end