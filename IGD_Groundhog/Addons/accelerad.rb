####################################################################
# EVERYTHING NEEDS TO BE WRAPPED WITHIN BOTH THE IGD AND GROUNDHOG
# MODULES, IN ORDER TO BE ABLE TO USE GROUNDHOG'S MODULES.
####################################################################

module IGD #this needs to be here
    module Groundhog #as well as this

        Sketchup.set_status_text "Loading Accelerad Add-on" ,SB_PROMPT #this puts a message in the status bar.



        # Then, add the name of your module (hopefully the Add-on name)
        module Accelerad

            @@config = Hash.new

            def self.config_path
                return "#{OS.addons_groundhog_path}/accelerad/config"
            end

            def self.get_program(program)
                return @@config[program]
            end


            def self.save_config
                path=self.config_path
				File.open(path,'w+'){ |f|
					f.write(@@config.to_json)
				}
            end




            #load info
            if File.exists? self.config_path then
                @@config=JSON.parse(File.open(self.config_path).read)
            end


            def self.show_wizard
				wd=UI::WebDialog.new(
					"Accelerad Config", false, "",
					310, 310, 100, 100, false )

				wd.set_file("#{OS.addons_groundhog_path}/accelerad/accelerad.html" )

                wd.add_action_callback("onLoad") do |web_dialog,msg|
                    next if not File.exists? self.config_path
                    d=JSON.parse(File.open(self.config_path).read)
                    script="document.getElementById('rtrace').value='#{d["rtrace"]}';"
                    web_dialog.execute_script(script)
                end


                 wd.add_action_callback("save_config") do |web_dialog,msg|
                    d=JSON.parse(msg)
                    @@config=d
                    self.save_config
                    UI.messagebox("Accelerad configuration saved succesfully!")
                 end

                wd.show
            end


            ####################################################################
            # ADD THE CORRESPONDING MENUS
            ####################################################################
            addon_submenu = IGD::Groundhog.addon_menu.add_item("Accelerad"){
                    self.show_wizard
            }

        end

        module OS
            def self.program(program)
                sys = self.getsystem
                if sys == "MAC" then
                    return program if not Accelerad.get_program(program)
                    return Accelerad.get_program(program)
                elsif sys == "WIN"
                    return "#{program}.exe" if not Accelerad.get_program(program)
                    return "#{Accelerad.get_program(program)}.exe"
                end
            end
        end
    end
end
