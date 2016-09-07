module IGD
    module Groundhog
        class CalcDaylightCoefficients < Task

            def initialize(workplane)
				#set the target (so this is repeated tor every workplane that needs it)
				@target = workplane
				
                @proc = Proc.new{ |options|					
					wp_file = "./Workplanes/#{Utilities.fix_name(workplane)}.pts"					
					#Alert and return if the file does not exist
                    if not File.file?(wp_file) then
						UI.messagebox("File '#{wp_file}' does not exist")
						next false
				    end

					# initialize the script
					script=[]
										
					wp_name = Utilities.fix_name(workplane)

					all_tdds = ["./DC/#{wp_name}-sky.dc"]

					#then add all the TDDs contributions
					unique_tdds=Dir["TDDs/*.pipe"].map{|x| x.split("/").pop.split(".").shift.split("-").pop}.uniq										
					unique_tdds.each{|tdd_name| #So, we add every TDD
						index = 0
						#and every instance of it
						while File.file? "./TDDs/#{index}-#{tdd_name}.pipe" do
							all_tdds << "./DC/#{wp_name}-#{index}-#{tdd_name}.dc"
							index+=1
						end
					}

					script << "rmtxop #{all_tdds.join(" + ")} > ./DC/#{wp_name}.dc"
				
					next script
                }

                @dependencies = [SkyContribution.new(workplane)]
				@dependencies << TDDContribution.new(workplane) if File.directory? "TDDs" #add only if it exists

            end
        end
    end
end