

require 'sketchup'
require 'extensions'
module IGD
	module Groundhog

		Groundhog = SketchupExtension.new "Groundhog", "IGD_Groundhog/src/Groundhog_main.rb"
		Groundhog.version = '0.7.2'
		Groundhog.description = "OpenSource SketchUp extension for creating, exporting and analyzing Radiance Models."
		Groundhog.creator='Germán Molina (gmolina1@uc.cl)'
		Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'


		Sketchup.register_extension Groundhog, true

	end #end module
end
