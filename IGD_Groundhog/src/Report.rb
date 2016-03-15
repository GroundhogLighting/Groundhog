module IGD
	module Groundhog
		module Report

      # Returns an array with the names of the workplanes, obtained from the Solved Workplanes
      # @author German Molina
      # @return [Array <String>] An array with the names of the workplanes
      def self.get_workplane_name_list
        return Utilities.get_solved_workplanes(Sketchup.active_model.entities).map{|x| JSON.parse(Labeler.get_value(x))["workplane"]}.uniq
      end

      # Returns an array with the names of the metrics within the solved-workplanes, obtained from the Solved Workplanes
      # @author German Molina
      # @return [Array <String>] An array with the names of the workplanes
      def self.get_metrics_list(group)
        Utilities.get_solved_workplanes(Sketchup.active_model.entities).map{|x| JSON.parse(Labeler.get_value(x))["metric"]}.uniq
      end

      # Exports a CSV with the values and statistics of a solved workplane
      # @author German Molina
      # @param group [Solved Workplane] A Solved Workplane that will be exported
      def self.report_csv(group)
        if not Labeler.solved_workplane? group then
          UI.messagebox "ERROR: Attempted to report a CSV file from a group that is not a Solved Workplane"
          return
        end

        begin
          op_name = "Export workplane to CSV"
          model.start_operation(op_name,true)

          path=Exporter.getpath #it returns false if not successful
          path="" if not path

          value=JSON.parse(Labeler.get_value(group))
          filename="#{Utilities.fix_name(value["name"])}_#{Utilities.fix_name(value["metric"])}.csv"
          filename=UI.savepanel("Export CSV file of results",path,filename)

          if filename then
            File.open(filename,'w'){|csv|
              statistics = Results.get_workplane_statistics(group)
              #write statistics
              statistics.to_a.each{|element|
                csv.puts "#{element[0]},#{element[1]}"
              }
              #Write header
              csv.puts "Position X, Position Y, Position Z, Value (depends on the metric)"
              #Write pixels
              pixels = group.entities.select{|x| Labeler.result_pixel?(x)}
              pixels.each do |pixel|
                vertices=pixel.vertices
                nvertices=vertices.length
                center=vertices.shift.position.to_a
                vertices.each{|vert|
                  pos=vert.position.to_a
                  center[0]+=pos[0]
                  center[1]+=pos[1]
                  center[2]+=pos[2]
                }
                csv.puts "#{(center[0]/nvertices).to_m},#{(center[1]/nvertices).to_m},#{(center[2]/nvertices).to_m},#{Labeler.get_value(pixel)}"
              end
            }
          end

          model.commit_operation
        rescue => e
          model.abort_operation
          OS.failed_operation_message(op_name)
        end
      end




    end # end REPORT module
  end # end Groundhog
end #end IGD
