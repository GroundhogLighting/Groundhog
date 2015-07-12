####################################################################
# EVERYTHING NEEDS TO BE WRAPPED WITHIN BOTH THE IGD AND GROUNDHOG
# MODULES, IN ORDER TO BE ABLE TO USE GROUNDHOG'S MODULES.
####################################################################

module IGD #this needs to be there
    module Groundhog #as well as this


        # Then, add the name of your module (hopefully the Add-on name)
        module DrawOffice

            Sketchup.set_status_text "Loading DrawOffice" ,SB_PROMPT #this puts a message in the status bar.


            def self.some_function
                UI.messagebox "some function output."
            end

            #Add the main sub-menu
            addon_submenu = IGD::Groundhog.addon_menu.add_submenu("Draw Office")


            #add different items to my submenu.
            addon_submenu.add_item("Draw"){
                self.some_function
            }

            addon_submenu.add_item("Do Nothing Much"){
                UI.messagebox("I do not really do anything, I am here just to show how to add a submenu.")
            }




        end
    end
end
