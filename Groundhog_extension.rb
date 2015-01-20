

require 'sketchup.rb'
require 'extensions.rb'

# You can have this sort of code in the initialization routine of your plugin.
version_required = 13.0

if (Sketchup.version.to_f < version_required) 
  UI.messagebox("You must have Sketchup " + version_required.to_s +
                " to run Groundhog. Visit SketchUp.com to upgrade.")

else
	Groundhog = SketchupExtension.new "Groundhog", "Groundhog/Groundhog.rb"
	Groundhog.version = '0.5'
	Groundhog.description = "OpenSource SketchUp extension for exporting Radiance Models, focused on annual daylight simulations"
	Groundhog.creator='Germán Molina (germolinal@gmail.com), Sergio Vera, Waldo Bustamante'
	Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'


	Sketchup.register_extension Groundhog, true

end




