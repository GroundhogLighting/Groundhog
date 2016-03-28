module IGD
	module Groundhog

        class LoadHandler

           def onPercentChange(p)
             Sketchup::set_status_text("LOADING:    " + p.to_i.to_s + "%")
           end

           def cancelled?
             # You could, for example, show a messagebox after X seconds asking if the
             # user wants to cancel the download. If this method returns true, then
             # the download cancels.
             return false
           end

           def onSuccess
             Sketchup::set_status_text('Loading completed succesfully.')
           end

           def onFailure(error_message)
             # A real implementation would probably not use a global variable,
             # but this demonstrates storing any error we receive.
             $last_error = error_message
			 UI.messagebox("ERROR: '#{error_message}' while trying to load the component.\n\nPlease contact #{Groundhog.creator} to tell us what happened.\n\nTHANKS!")
           end

        end

		module Loader

			# Open the Arqhub API gui
			# @author German Molina
			# @version 0.1
			def self.open_arqhub
				wd=UI::WebDialog.new(
					"Archive", false, "",
					400, 600, 100, 100, false)
				wd.set_file("#{OS.main_groundhog_path}/src/html/arqhub.html" )
				wd.show

				wd.add_action_callback("get_model") do |web_dialog,msg|
					product = JSON.parse(msg)
					self.load_from_arqhub(product)
				end
			end

			#Loads a product from the Arqhub database
			# @author German Molina
			# @version 0.1
			# @param product [String] a JSON object that contains information about the product, which is used to download and import files.
			# @return [Boolean] Success
			def self.load_from_arqhub(product)
				domain = "http://localhost:8080"
				ies_destination = "/Users/German/Desktop"

				component = self.load_component("#{domain}/api/products/#{product["_id"]}.skp")
				return false if not component
				component.name = "#{product["brand"]} - #{product["name"]}"

				File.open("#{ies_destination}/test.ies", "wb") do |saved_file|
				  open("#{domain}/api/products/#{product["_id"]}.ies", "rb") do |read_file|
				    saved_file.write(read_file.read)
				  end
				end

				return true

			end

			# Loads a component from a url
			# @author German Molina
			# @version 0.1
			# @param url [String] The url where the component is
			# @return [Boolean] Sketchup::ComponentDefinition is success, false if not
			def self.load_component(url)
				loader=LoadHandler.new
				Sketchup.active_model.definitions.load_from_url(url,loader)
				if $last_error == nil
				   last_def_id = Sketchup.active_model.definitions.count - 1
				   return Sketchup.active_model.definitions[last_def_id]
				 else
				   return false
				 end
			end

			# Imports a model from a local url, in the Groundhog path.
			# @author German Molina
			# @version 0.1
			# @param name [String] name of the SKP file
			# @return [Boolean] Sketchup::ComponentDefinition is success, false if not
			def self.load_local_component(name)
				url = "file:#{OS.support_files_groundhog_path}/#{name}.skp"
				return self.load_component(url)
			end

			# Loads the Illuminance Sensor component to the model
			# @author German Molina
			# @version 0.1			
			# @return [Boolean] Sketchup::ComponentDefinition is success, false if not
			def self.load_illuminance_sensor
				sensors = Sketchup.active_model.definitions.select {|x| Labeler.illuminance_sensor?(x) }

				# Load it if it is not there
				if sensors.length < 1 then
					sensor = self.load_local_component("illuminance_sensor")
					return false if not sensor
					sensor.name="GH Illuminance sensor"
					sensor.description="This represents an illumiance sensor."
					sensor.casts_shadows= false
					sensor.receives_shadows= false
					Labeler.to_illuminance_sensor(sensor);
				end
				UI.messagebox("Success!\n\nThe Illuminance sensor has been added to the Model Components.\n\nYou can find it in Window --> Components")
				return true
			end


		end
    end
end
