module IGD
    module Groundhog 
        class TDDContribution < Task

			def initialize(target)
				@target = target #the workplane

				@proc = Proc.new{|options|
					next [] if not File.directory? "TDDs" #this is success... just nothing to do.
					
					script = []
					unique_tdds=Dir["TDDs/*.pipe"].map{|x| x.split("/").pop.split(".").shift.split("-").pop}.uniq
					
					wps=Dir["Workplanes/*.pts"]										

					

					### Fourth: Multiply all the parts of all TDDs
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						wp_name = Utilities.fix_name(name)
						unique_tdds.each{|tdd_name|
							index = 0
							while File.file? "TDDs/#{index}-#{tdd_name}.pipe" do
								top_lens_bsdf = "./TDDs/#{tdd_name}_top.xml" #has to match the one given in TDD.write_tdd
								bottom_lens_bsdf= "./TDDs/#{tdd_name}_bottom.xml"
								daymtx = "DC/#{index}-#{wp_name}-sky.mtx"
								daymtx = "DC/ALL_TDDs-sky.mtx" if Config.tdd_singledaymtx
								script << "rmtxop DC/#{wp_name}-#{index}-#{tdd_name}.vmx #{bottom_lens_bsdf.strip} DC/#{tdd_name}-pipe.mtx #{top_lens_bsdf.strip} #{daymtx} > DC/#{wp_name}-#{index}-#{tdd_name}.dc"
								index+=1
							end
						}

					end
					next script
				}
			
	            @dependencies = [TDDDaylight.new(target), TDDPipe.new(target), TDDView.new(target)]
			end
        end        
    end
end