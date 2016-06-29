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
                            next ["rfluxmtx #{Config.tdd_daylight_rfluxmtx} #{tdd_file} Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/ALL_TDDs-sky.mtx"]
                        end						
					else
						next ["rfluxmtx #{Config.tdd_daylight_rfluxmtx} #{sender} Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/#{name}-sky.mtx"]					
					end
                }

                @dependencies = [WriteWhiteSky.new]
            end

        end
    end
end