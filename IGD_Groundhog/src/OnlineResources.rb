module IGD
  module Groundhog
    module OnlineResources

      # Returns the Online Resources Dialog
      #
      # @author German Molina
      # @return [SketchUp::UI::WebDialog] the Design Assistant web dialog
      def self.get
        # We will use WEBDIalogs for now... unfortunately.

        wd = Utilities.build_web_dialog("Groundhog Online Resources",false,"GHCloud",500,500,true,"http://localhost:8000/skpapp")


        # Receives
        wd.add_action_callback("download_json_object") do |action_context,json|
          object = JSON.parse(json)
          warn object.inspect
          case object["resource_class"]
          when "material"
            Materials.add_material(JSON.parse(json))
          when "objective"
            warn "it is an Objective!"
          else
            Error.inform_exception("Unkown object type when downloading JSON from Online Resources")
          end
          DesignAssistant.update
        end


        return wd
      end

    end
  end
end
