module IGD
    module Groundhog 
        class SkyContribution < Task

            def initialize(target)
                @target = target

                @proc = Proc.new{|options|
                    wp_file = "Workplanes/#{Utilities.fix_name(@target)}.pts"
					#Alert and return if the file does not exist
                    if not File.file?(wp_file) then
						UI.messagebox("File '#{wp_file}' does not exist")
						next false
				    end
                    win_string = ""
                    win_string = "./Windows/windows.rad" if File.directory? "Windows"  
                    
                    name=Utilities.fix_name(target)
                    nsensors = File.readlines(wp_file).length
                    script = "rfluxmtx -I+ -y #{nsensors} #{options["dc_parameters"]} < ./#{wp_file} - ./Skies/white_sky.rad ./Materials/materials.mat ./scene.rad #{win_string} > ./DC/#{name}-sky.dc" 
                    
                    next [script]
                }

                @dependencies = [WriteWhiteSky.new]
            end

        end        
    end
end