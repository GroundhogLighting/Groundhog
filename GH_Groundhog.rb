

require 'sketchup'
require 'extensions'
module GH
	module Groundhog

		Groundhog = SketchupExtension.new "Groundhog", "GH_Groundhog/src/Groundhog_main"
		Groundhog.copyright='Germán Molina, Sergio Vera, Waldo Bustamante'
		Groundhog.creator='Germán Molina (germolinal@gmail.com)'
		Groundhog.description = "Open Source SketchUp extension for performing Lighting simulation"
		Groundhog.name = 'Groundhog'
		Groundhog.version = '1.0.0.b'
		Sketchup.register_extension Groundhog, true

	end #end module
end
