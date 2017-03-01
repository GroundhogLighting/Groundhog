module IGD
  module Groundhog
    module OnlineResources

      # Returns the Online Resources Dialog
      #
      # @author German Molina
      # @return [SketchUp::UI::WebDialog] the Design Assistant web dialog
      def self.get
        # We will use WEBDIalogs for now... unfortunately.

        wd = Utilities.build_web_dialog("Groundhog Online Resources",false,"GHCloud",500,500,true,"http://www.groundhoglighting.com/skp")


        # 
        wd.add_action_callback("download_json_object") do |action_context,json|
          object = JSON.parse(json)
          case object["kind"]
          when "material"
            Materials.add_material(object)
          when "objective"
            Objectives.create_objective(object)
          else
            Error.inform_exception("Unkown object type when downloading JSON from Online Resources")
          end
          DesignAssistant.update
        end

        # Receives
        wd.add_action_callback("follow_link") do |action_context,link|
          UI.openURL(link)
        end

        return wd
      end # end of get metho

    end
  end
end
