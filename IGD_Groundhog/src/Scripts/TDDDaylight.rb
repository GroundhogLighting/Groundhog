module IGD
    module Groundhog

        class TDDDaylight < Task

            def initialize(target)
                @target = target

                @proc = Proc.new { |options|
                    tdd_file = "TDDs/#{Utilities.fix_name(target)}.top"
					
					if options["tdd_singledaymtx"] then
                        if File.file? "DC/ALL_TDDs-sky.mtx" then #if it has been calculated
                            next []
                        else #calculate it
                            next ["rfluxmtx #{options["tdd_daylight_parameters"]} #{tdd_file} Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/ALL_TDDs-sky.mtx"]
                        end						
					else
						next ["rfluxmtx #{options["tdd_daylight_parameters"]} #{sender} Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/#{name}-sky.mtx"]					
					end
                }

                @dependencies = [WriteWhiteSky.new]
            end

        end
    end
end