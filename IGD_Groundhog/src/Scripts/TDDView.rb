module IGD
    module Groundhog

        class TDDView < Task

            def initialize(workplane)
                @target = workplane #the workplane

                @proc = Proc.new { |options|
                    
                    wp_name = Utilities.fix_name(workplane)	
					wp_file = "Workplanes/#{wp_name}.pts"
                    				
										
					nsensors = File.readlines(wp_file).length
					
					bottoms = ""
					Dir["TDDs/*.bottom"].each{|bottom| #get all the TDD bottoms.
						info=bottom.split("/")
						tdd_name=info[1].split(".")[0]
						bottoms += "\#@rfluxmtx h=kf u=Y o=DC/#{wp_name}-#{tdd_name}.vmx\n\n"
						bottoms += File.open(bottom, "rb").read
					}

					File.open("DC/#{wp_name}_receiver.rad",'w'){|x| x.puts bottoms}

					win_string = ""
                    win_string = "./Windows/windows.rad" if File.directory? "Windows"  

					next ["rfluxmtx -y #{nsensors} -I+ #{options["tdd_view_parameters"]} < #{wp_file} - DC/#{wp_name}_receiver.rad Materials/materials.mat scene.rad #{win_string}"]
								
                }

            end

        end



    end
end