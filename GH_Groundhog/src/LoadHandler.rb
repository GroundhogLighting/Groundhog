module GH
    module Groundhog

        # This class was obtained directly from SketchUp's examples
        class LoadHandler

                # AAA
                def onPercentChange(p)
                    Sketchup::set_status_text("LOADING:    " + p.to_i.to_s + "%")
                end

                # AAA
                def cancelled?
                    # You could, for example, show a messagebox after X seconds asking if the
                    # user wants to cancel the download. If this method returns true, then
                    # the download cancels.
                    return false
                end

                # AAA
                def onSuccess
                    Sketchup::set_status_text('Loading completed succesfully.')
                end

                # AAA
                def onFailure(error_message)
                    # A real implementation would probably not use a global variable,
                    # but this demonstrates storing any error we receive.
                    $last_error = error_message
                    UI.messagebox("ERROR: '#{error_message}' while trying to load the component.\n\nPlease contact #{Groundhog.creator} to tell us what happened.\n\nTHANKS!")
                end

        end


        # This module aims to control the process of loading object from the internet
        # or internal.... it is terribly under developed, though.
        module Loader

            

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

            

        end
    end
end
