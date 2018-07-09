

require 'sketchup'
require 'extensions'
module IGD
	module Groundhog

		Groundhog = SketchupExtension.new "Groundhog", "IGD_Groundhog/src/Groundhog_main"
		Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'
		Groundhog.creator='Germán Molina (germolinal@gmail.com)'
		Groundhog.description = "Open Source SketchUp extension for performing Lighting simulation using Radiance."
		Groundhog.name = 'Groundhog'
		Groundhog.version = '0.9.7'
		Sketchup.register_extension Groundhog, true

	end #end module
end
