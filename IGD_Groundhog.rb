

require 'sketchup.rb'
require 'extensions.rb'

# You can have this sort of code in the initialization routine of your plugin.
version_required = 15
actual_version = Sketchup.version_number

if (actual_version < version_required) 
  UI.messagebox("Groundhog is being developed and tested using Sketchup 20" + version_required.to_i.to_s +
                ". Since it seems that you are using an older version, some features might not work correctly for you."+
                "\n\n You can upgrade SketchUp going to "+
                "www.SketchUp.com")

end
	Groundhog = SketchupExtension.new "Groundhog", "IGD_Groundhog/Groundhog_main.rb"
	Groundhog.version = '0.5.6'
	Groundhog.description = "OpenSource SketchUp extension for exporting Radiance Models, focused on annual daylight simulations"
	Groundhog.creator='Germán Molina (gmolina1@uc.cl)'
	Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'


	Sketchup.register_extension Groundhog, true






