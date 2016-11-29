module IGD
    module Groundhog


        class SkyVisibility < Task
            def initialize(workplane)
                #target is a Hash with the sky and the
                #name of the workplane
                @target = workplane
                @dependencies = [WriteWhiteSky.new]
                @proc = Proc.new {|options|
                    script = []

                    wp_file = "./Workplanes/#{Utilities.fix_name(@target)}"
                    next false if not File.file? "#{wp_file}.pts"
                    wp_file="#{wp_file}.pts"

                    nsensors = File.readlines(wp_file).length

                    File.open("black_scene.rad",'w'){ |f| f.puts "void plastic black 0 0 5 0 0 0 0 0" }

                    script << "xform -m black ./scene.rad >> ./black_scene.rad"
                    script << "oconv ./black_scene.rad ./Skies/white_sky.rad > ./black_octree.oct"
                    script << "rtrace -I+ -h -af sky_visibility.amb -ab 1 -ad 30000 ./black_octree.oct < #{wp_file} > tmp1-sky_visibility.tmp"
                    script << "rcollate -oc 1 -hi -or #{nsensors} -oc 1 ./tmp1-sky_visibility.tmp > tmp2-sky_visibility.tmp"
                    script << "rmtxop -fa -c 47.435 119.93 11.635 ./tmp2-sky_visibility.tmp > tmp3-sky_visibility.tmp"
                    script << "rcollate -oc 1 -ho  ./tmp3-sky_visibility.tmp > ./Results/#{Utilities.fix_name(@target)}-sky_visibility.txt"

                    next script

                }
            end
        end

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

                    next false if not File.file? "#{wp_file}.pts"


                    wp_file="#{wp_file}.pts"

                    nsensors = File.readlines(wp_file).length

                    script << "#{OS.oconv_command( {:lights_on => false, :sky => sky})} > octree-#{sky}.oct"
                    script << "rtrace -I+ -h -af #{sky}.amb #{options["ray_tracing_parameters"]} ./octree-#{sky}.oct < #{wp_file} > tmp1-#{sky}.tmp"
                    script << "rcollate -oc 1 -hi -or #{nsensors} -oc 1 ./tmp1-#{sky}.tmp > tmp2-#{sky}.tmp"
                    script << "rmtxop -fa -c 47.435 119.93 11.635 ./tmp2-#{sky}.tmp > tmp3-#{sky}.tmp"
                    script << "rcollate -oc 1 -ho  ./tmp3-#{sky}.tmp > ./Results/#{Utilities.fix_name(@target["workplane"])}-#{sky}.txt"

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
