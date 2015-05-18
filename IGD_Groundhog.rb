

require 'sketchup'
require 'extensions'
module IGD
	module Groundhog

		Groundhog = SketchupExtension.new "Groundhog", "IGD_Groundhog/src/Groundhog_main.rb"
		Groundhog.version = '0.6.7'
		Groundhog.description = "OpenSource SketchUp extension for exporting Radiance Models, focused on annual daylight simulations"
		Groundhog.creator='Germán Molina (gmolina1@uc.cl)'
		Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'


		Sketchup.register_extension Groundhog, true

	end #end module
end