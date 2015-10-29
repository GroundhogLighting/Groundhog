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

			def self.load_local_component(name)
				url = "file:#{OS.support_files_groundhog_path}/#{name}.skp"
				return self.load_component(url)
			end

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
