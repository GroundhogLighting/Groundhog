module IGD
    module Groundhog
        module Addons

            # Loads a list of addons passed to it in an array of strings
            # @param addons [String <Array>] An array of Strings that contains the names of the addons.
    		# @author German Molina
            # @param addons [<String>] A list with the names of the active addons (if I remember correctly)
            def self.load_addons(addons)
                available= Dir["#{OS.addons_groundhog_path}/*.rb"]
                available.map!{|x| x.tr("\\","/").split("/").pop}

                addons.each do |a|
                    next if not available.include? a #if may still be in the list, although it may have been removed.
                    if not Sketchup.load "#{OS.addons_groundhog_path}/#{a}" then
                        UI.messagebox "Module '#{a}' could not be loaded.\n\nYou can deactivate it to avoid seeing this message again."
                    end
                end
            end

            # Show the Add-ons manager web dialog
    		# @author German Molina
            def self.show_addons_manager
                wd=UI::WebDialog.new(
                    "Addons manager", false, "",
                    450, 550, 100, 100, false )

                wd.set_file("#{OS.main_groundhog_path}/src/html/addons.html" )


                #Load the active and inactive addons
                wd.add_action_callback("onLoad") do |web_dialog,msg|
                    active=Config.active_addons
                    all = Dir["#{OS.addons_groundhog_path}/*.rb"]
                    all.map!{|x| x.split("/").pop}

                    str="var active=document.getElementById('active_addons');"
                    str+="var inactive=document.getElementById('inactive_addons');"


                    all.each do |addon|
                        str+="var opt = document.createElement('option');"
                        dir = addon.split(".")
                        dir.pop
                        dir=dir.join(",")


                        info_file="#{OS.addons_groundhog_path}/#{dir}/info.txt"
                        if File.exist? info_file then #if there is an info file
                            info=JSON.parse(File.open(info_file).read)

                            str+="opt.setAttribute('name','#{info["name"]}');" if info["name"] != nil
                            str+="opt.setAttribute('developer','#{info["developer"]}');" if info["developer"] != nil
                            str+="opt.setAttribute('version','#{info["version"]}');" if info["version"] != nil
                            str+="opt.setAttribute('support','#{info["support"]}');" if info["support"] != nil
                            str+="opt.setAttribute('info','#{info["license"]}');" if info["license"] != nil
                            str+="opt.setAttribute('info','#{info["info"]}');" if info["info"] != nil
                            str+="opt.innerHTML='#{info["name"]}';"
                        else
                            str+="opt.setAttribute('info','ANONYMUS ADD-ON. BE AWARE OF THAT');"
                            shown_name = addon.split(".")
                            shown_name.pop
                            shown_name=shown_name.join(".").tr("_"," ")
                            str+="opt.innerHTML='#{shown_name}';"
                        end

                        str+="opt.value='#{addon}';"

                        str+="active.appendChild(opt);" if active.include? addon
                        str+="inactive.appendChild(opt);" if not active.include? addon

                    end
                    web_dialog.execute_script(str)
                end

                wd.add_action_callback("save_addon_conf") do |web_dialog,msg|
					#the message is the list of active addon names separated by commas
                    Config.set_active_addons(msg)
                    UI.messagebox "Preferences saved succesfully!\n\nPlease restart SketchUp for the new configuration to take effect."
				end

                wd.add_action_callback("install_addon") do |web_dialog,msg|
                    path = UI.openpanel("Install addon", path, "ruby file (.rb, .rbz) | *.rb; *.rbz ||")
                    next if not path

                    path=path.tr("\\","/").split("/")
                    addon_name=path.pop
                    path=File.join(path)
                    support_name=addon_name.split(".")
                    support_name.pop
                    support_name=support_name.join(".")

                    final_addon="#{OS.addons_groundhog_path}/#{addon_name}"
                    final_support="#{OS.addons_groundhog_path}/#{support_name}"

                    support = true
                    #Check if there is any addon with the same name
                    if File.exist? final_addon or File.directory? final_support then
                        next if UI.messagebox('There is already an Add-on with this name installed. Do you want to replace it?', MB_YESNO) != IDYES
                        begin
                            FileUtils.rm(final_addon) if File.exist? final_addon
                            FileUtils.rm_rf(final_support) if File.directory? final_support
                          rescue Exception => ex
              							UI.messagebox ex
                        end
                    end

                    #Check if there are any support files
                    if not File.directory? "#{path}/#{support_name}" then
                        support = false
                        next if UI.messagebox('There were no support files found. Is that OK?', MB_YESNO) != IDYES
                    end

                    begin
                        FileUtils.cp("#{path}/#{addon_name}",final_addon)
                        FileUtils.cp_r("#{path}/#{support_name}",final_support) if support
                        UI.messagebox "Add-on installed succesfully"
                        #add it to the list
                        shown_name = addon_name.split(".")
                        shown_name.pop
                        shown_name=shown_name.join(".").tr("_"," ")
                        str="var active=document.getElementById('active_addons');"
                        str+="var inactive=document.getElementById('inactive_addons');"
                        str+="var opt = document.createElement('option');"
                        str+="opt.value='#{addon_name}';"
                        str+="opt.innerHTML='#{shown_name}';"
                        str+="inactive.appendChild(opt);"
                        web_dialog.execute_script(str)
                      rescue Exception => ex
          							UI.messagebox ex
                    end

                end


                wd.show
            end

        end #end addons module
    end #end GH module
end #end IGD module
