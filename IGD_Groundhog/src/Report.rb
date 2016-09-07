module IGD
    module Groundhog
        module Report

            # Exports a CSV with the values and statistics of a solved workplane
            # @author German Molina
            # @param group [Solved Workplane] A Solved Workplane that will be exported
            def self.report_csv(group)
                if not Labeler.solved_workplane? group then
                    UI.messagebox "ERROR: Attempted to report a CSV file from a group that is not a Solved Workplane"
                    return
                end

                path=Exporter.getpath #it returns false if not successful
                path="" if not path

                value=JSON.parse(Labeler.get_value(group))
                filename="#{Utilities.fix_name(value["workplane"])}_#{Utilities.fix_name(value["objective"])}.csv"
                filename=UI.savepanel("Export CSV file of results",path,filename)

                if filename then
                    File.open(filename,'w'){|csv|
                        #write statistics
                        value.each{|key,val|
                            csv.puts "#{key},#{val}"
                        }
                        #Write header
                        csv.puts "Pixel area (m2),Position X,Position Y,Position Z,Value (Lux or %... depends on the metric)"
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
                            csv.puts "#{pixel.area/1550.0},#{(center[0]/nvertices).to_m},#{(center[1]/nvertices).to_m},#{(center[2]/nvertices).to_m},#{Labeler.get_value(pixel)}"
                        end
                    }
                end            
            end




        end
    end
end