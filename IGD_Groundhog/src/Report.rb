module IGD
	module Groundhog
		module Report

			def self.show_report_wizard
				wd=UI::WebDialog.new(
					"Report wizard", false, "",
					595, 490, 100, 100, false )

				wd.set_file("#{OS.main_groundhog_path}/src/html/report.html" )

				wd.add_action_callback("on_load") do |web_dialog,msg|
					metrics = self.get_metrics_list
					script = ""
					script += self.refresh_metrics(metrics)
					script += self.refresh_table(metrics[0])
					web_dialog.execute_script(script)
				end				

				wd.add_action_callback("select_metric") do |web_dialog,msg|
					metric = web_dialog.get_element_value("metrics")
					script = ""
					script += self.refresh_table(metric)
					web_dialog.execute_script(script)
				end

				wd.show()
			end

			# Returns a script that needs to be run to update the metrics input box
			# @author German Molina
			# @param metrics [Array<String>] An array of strings with the entities
			# @return [String] The javascript script that needs to be run to update the metrics input box
			def self.refresh_metrics(metrics)
				script = "var select = document.getElementById('metrics');"
				metrics.each do |metric|
					value = metric
					script += "var option =  document.createElement('option');"
					script += "option.value = '#{value}';"
					script += "option.text = '#{metric}';"
					script += "select.add(option);"
				end
				return script
			end


			# Returns a script that needs to be run to update the metric results table
			# @author German Molina
			# @return [String] The javascript script that needs to be run to update the metric results table
			def self.refresh_table(metric)
				#get all workplanes
				workplanes = self.get_workplane_list
				Utilities.remark_solved_workplanes(metric)
				#select those with the corresponding metric
				workplanes = workplanes.select{|x| JSON.parse(Labeler.get_value(x))["metric"] == metric}
				#get the script
				script=""
				script += "var table = document.getElementById('results');"
				script += "table.innerHTML = '<tr><td></td><td>Average</td><td>Minimum</td><td>Maximum</td><td>Min / Average</td><td>Min / Max</td></tr>';"
				workplanes.each do |workplane|
					data = JSON.parse(Labeler.get_value(workplane))

					script += "var row = table.insertRow(-1);"
					#name
					script += "var cell = row.insertCell(0);"
					script += "cell.innerHTML='#{data["workplane"]}';"
					#Average
					script += "cell = row.insertCell(1);"
					script += "cell.innerHTML='#{data["average"].round(1)}';"
					#Minimum
					script += "cell = row.insertCell(2);"
					script += "cell.innerHTML='#{data["min"].round(1)}';"
					#Maximum
					script += "cell = row.insertCell(3);"
					script += "cell.innerHTML='#{data["max"].round(1)}';"
					#Min/Average
					script += "cell = row.insertCell(4);"
					script += "cell.innerHTML='#{data["min_over_average"].round(3)}';"
					#Min/Max
					script += "cell = row.insertCell(5);"
					script += "cell.innerHTML='#{data["min_over_max"].round(3)}';"
				end
				return script
			end


      # Returns an array with the names of the workplanes, obtained from the Solved Workplanes
      # @author German Molina
      # @return [Array <String>] An array with the names of the workplanes
      def self.get_workplane_name_list
        Utilities.get_solved_workplanes(Sketchup.active_model.entities).map{|x| JSON.parse(Labeler.get_value(x))["workplane"]}.uniq
      end

			# Returns an array with the solved workplanes in the model
			# @author German Molina
			# @return [Array <String>] An array with the names of the workplanes
			def self.get_workplane_list
				Utilities.get_solved_workplanes(Sketchup.active_model.entities)
			end

      # Returns an array with the names of the metrics within the solved-workplanes, obtained from the Solved Workplanes
      # @author German Molina
      # @return [Array <String>] An array with the names of the metrics
      def self.get_metrics_list
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
