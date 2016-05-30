

require 'sketchup'
require 'extensions'
module IGD
	module Groundhog

		Groundhog = SketchupExtension.new "Groundhog", "IGD_Groundhog/src/Groundhog_main"
		Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'
		Groundhog.creator='Germán Molina (gmolina@igd.cl)'
		Groundhog.description = "Open Source SketchUp extension for creating, exporting and analyzing Radiance Models."
		Groundhog.name = 'Groundhog'
		Groundhog.version = '0.9.0'
		Sketchup.register_extension Groundhog, true

	end #end module
end
