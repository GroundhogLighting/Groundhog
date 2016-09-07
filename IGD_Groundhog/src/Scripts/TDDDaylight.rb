module IGD
    module Groundhog

        class TDDDaylight < Task

            def initialize(target)
                @target = target

                @proc = Proc.new { |options|
                    tdd_file = "./TDDs/#{target}.top"

					daylight_matrix = "./DC/#{target}-sky.mtx"
					#daylight_matrix = "DC/ALL_TDDs-sky.mtx" if options["tdd_singledaymtx"] 
                    #next [] if options["tdd_singledaymtx"]
                    win_string = ""
                    win_string = "./Windows/windows.rad" if File.directory? "Windows"

                    next ["rfluxmtx #{options["tdd_daylight_parameters"]} #{tdd_file} ./Skies/white_sky.rad ./Materials/materials.mat ./scene.rad #{win_string} > #{daylight_matrix}"]                     
                }

                @dependencies = [WriteWhiteSky.new]
            end

        end
    end
end