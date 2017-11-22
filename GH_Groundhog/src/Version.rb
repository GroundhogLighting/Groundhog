module GH
    module Groundhog
        module Version

            def self.model_groundhog_version
                Sketchup.active_model.get_attribute("Groundhog",VERSION_KEY)
            end

            def self.installed_groundhog_version
                Sketchup.extensions["Groundhog"].version.to_s
            end

            def self.update_model_groundhog_version
                Sketchup.active_model.set_attribute("Groundhog",VERSION_KEY,installed_groundhog_version())
            end

            # Compares a two version strings in format "A.B.C"
			#
			# If they are the same, it returns 0... if the first one is older,
			# returns 1; if the first one is newer, returns -1.
			# @author German Molina
			# @return [Integer] The number.
			# @param older [String] A version number in string format (A.B.C)
			# @param newer [String] A version number in string format (A.B.C)
            def self.compare_versions(older,newer)
				return 0 if older == newer
				older = older.split(".").map{|x| x.to_i}
				newer = newer.split(".").map{|x| x.to_i}
				3.times { return -1 if newer.shift < older.shift}
				return 1
            end

            def self.check_version_compatibility

                
                model_groundhog_version = model_groundhog_version()
                current_groundhog_version = installed_groundhog_version()   
                
                if model_groundhog_version == nil then
                    update_model_groundhog_version()                    
                else
                    # Do something about compatibility!
                    compare = compare_versions(current_model_version,current_groundhog_version)                    
                    if compare < 0 then #model version is newer than GH version
                        UI.messagebox("We are sorry. This model was edited using a newer version (#{current_model_version}) than the one you have installed (#{current_groundhog_version}). You may have to redefine all Workplanes and Objectives.")
                    else #model version is older than GH version.
                        UI.messagebox("This model was developed using an older version of Groundhog (#{current_model_version}). Unfortunately, compatibility was ")
                    end
                end
                
            end
        end
    end
end