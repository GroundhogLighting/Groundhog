####################################################################
# EVERYTHING NEEDS TO BE WRAPPED WITHIN BOTH THE IGD AND GROUNDHOG
# MODULES, IN ORDER TO BE ABLE TO USE GROUNDHOG'S MODULES.
####################################################################

module IGD #this needs to be here
    module Groundhog #as well as this


        # Then, add the name of your module (hopefully the Add-on name)
        module ExportScript

            Sketchup.set_status_text "Loading ExportScript Add-on" ,SB_PROMPT #this puts a message in the status bar.


            ####################################################################
            # NOW WRITE THE NEEDED FUNCTIONS
            ####################################################################

            def self.export_script(script)
                return false if not script
                path=Exporter.getpath
                path="c:/" if not path
                path = UI.savepanel("Export Script", path, "script")
                return false if not path

                File.open(path,'w'){ |f|
                    script.each do |ln|
                        f.write "#{ln}\n\n"
                    end
                }
                return true
            end

            def self.show_wizard
				wd=UI::WebDialog.new(
					"Export Script wizard", false, "",
					595, 490, 100, 100, false )

				wd.set_file("#{OS.addons_groundhog_path}/export_script/ui.html" )



                 wd.add_action_callback("calc_DF") do |web_dialog,msg|
                     next if not Exporter.export(OS.tmp_groundhog_path)
                     script=[]
                     FileUtils.cd(OS.tmp_groundhog_path) do
                         Exporter.export(OS.tmp_groundhog_path)
                         OS.mkdir("Results")
                         script=Rad.daylight_factor
                         OS.clear_actual_path
                     end
                     next if not self.export_script(script)
                 end

                 wd.add_action_callback("calc_actual_illuminance") do |web_dialog,msg|
                     next if not Exporter.export(OS.tmp_groundhog_path)
                     options=JSON.parse(msg)
                     script=[]
                     FileUtils.cd(OS.tmp_groundhog_path) do
                         Exporter.export(OS.tmp_groundhog_path)
                         OS.mkdir("Results")
                         script = Rad.actual_illuminance(options)
                         OS.clear_actual_path
                     end
                    next if not self.export_script(script)
                 end

                 wd.add_action_callback("calc_annual_illuminance") do |web_dialog,msg|
                    next if not Exporter.export(OS.tmp_groundhog_path)
                    options=JSON.parse(msg)
                    path=OS.tmp_groundhog_path
                    script=[]
     				FileUtils.cd(path) do
     					script =Rad.calc_annual_illuminance(options)
                    end
                    next if not self.export_script(script)
                 end

                wd.show
            end


            ####################################################################
            # ADD THE CORRESPONDING MENUS
            ####################################################################
            addon_submenu = IGD::Groundhog.addon_menu.add_submenu("Export Scripts")

            #Add different items to my submenu.
            addon_submenu.add_item("Wizard"){
                self.show_wizard
            }

            addon_submenu.add_item("Do Nothing Much"){
                UI.messagebox("I do not really do anything, I am here just to show how to add a submenu.")
            }

        end
    end
end
