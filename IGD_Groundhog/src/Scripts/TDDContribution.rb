module IGD
    module Groundhog 
        class TDDContribution < Task

			def initialize(workplane)
				@target = workplane #the workplane

				@proc = Proc.new{|options|
					next false if not File.directory? "TDDs" #this is called when TDDs does exist... if it does not exist at this point; alarm
					 	

					script = []
					unique_tdds=Dir["TDDs/*.pipe"].map{|x| x.split("/").pop.split(".").shift.split("-").pop}.uniq
							
					wp_name = Utilities.fix_name(@target)
					unique_tdds.each{|tdd_name|
						index = 0
						while File.file? "TDDs/#{index}-#{tdd_name}.pipe" do
							top_lens_bsdf = "./TDDs/#{tdd_name}_top.xml" #has to match the one given in TDD.write_tdd
							bottom_lens_bsdf= "./TDDs/#{tdd_name}_bottom.xml"
							daymtx = "DC/#{index}-#{wp_name}-sky.mtx"
							#daymtx = "DC/ALL_TDDs-sky.mtx" if options["tdd_singledaymtx"]
							script << "rmtxop DC/#{wp_name}-#{index}-#{tdd_name}.vmx #{bottom_lens_bsdf.strip} DC/#{tdd_name}-pipe.mtx #{top_lens_bsdf.strip} #{daymtx} > DC/#{wp_name}-#{index}-#{tdd_name}.dc"
							index+=1
						end
					}

					next script
				}

				# Initiate the dependencies with the calculation of the view matrix
				@dependencies = [TDDView.new(workplane)]

				# Resolve all the TDD pipes				
				Dir["TDDs/*_bottom.xml"].each{|tdd|
					tdd = tdd.gsub("_bottom.xml","").gsub("TDDs/","")
					@dependencies << TDDPipe.new(tdd)
				}

				# Resolve the Daylight matrices
				Dir["TDDs/*.top"].each{|file|
					tdd = file.gsub(".top","").gsub("TDDs/","")
					@dependencies << TDDDaylight.new(tdd)					
				}
				
				
	            
			end
        end        
    end
end