module IGD
    module Groundhog

        class TDDView < Task

            def initialize(target)
                @target = target

                @proc = Proc.new { |options|
                    next []
                    tdd_name = Utilities.fix_name(target)					
                    ### Second, calculate the View matrices
					wps.each do |workplane|
						bottoms = ""
						info=workplane.split("/")
						name=info[1].split(".")[0]
						wp_name = Utilities.fix_name(name)
						nsensors = File.readlines(workplane).length

						Dir["TDDs/*.bottom"].each{|bottom| #get all the TDD bottoms.
							info=bottom.split("/")
							tdd_name=info[1].split(".")[0]
							bottoms += "\#@rfluxmtx h=kf u=Y o=DC/#{wp_name}-#{tdd_name}.vmx\n\n"
							bottoms += File.open(bottom, "rb").read
						}

						File.open("DC/#{wp_name}_receiver.rad",'w'){|x| x.puts bottoms}

						script << "rfluxmtx -y #{nsensors} -I+ #{Config.tdd_view_rfluxmtx} < #{workplane} - DC/#{wp_name}_receiver.rad Materials/materials.mat scene.rad #{self.gather_windows}"
					end                
                }

            end

        end
    end
end