module GH
    module Groundhog
        module Error


            # Shows a UI.messagebox that does not say much, but informs the user that
            # there was an error. It also raises and prints in the console the error, so we can
            # know a bit more.
            # @author Germán Molina
            # @param ex [Exeption] The exception
            def self.inform_exception(ex)
                UI.messagebox ex
                raise ex
            end

            def self.warn(msg)
                warn "Groundhog Warning: #{msg}"
            end

            def self.error(msg)
                UI.messagebox "Groundhog Error: #{msg}"
            end
            
            def self.log(msg)
                caller_locations(1, 1).first.tap{|loc| 
                    puts " log:: #{loc.path.split('src').pop}:#{loc.lineno}:#{msg}"
                }
            end
            
        end
    end
end