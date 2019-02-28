
module GH
    module Groundhog
        module Results
            @N_BINS_PALLETE=20
            @BIN_SIZE=1.0/@N_BINS_PALLETE
            @COLOR_PREFIX = "GroundhogScale_"

            def self.add_color_pallete

                # Check if it already exist
                return if Sketchup.active_model.materials["#{@COLOR_PREFIX}0"] != nil

                # Basic pallete, by Lucas and Gonzalo
                #red =   [8,  43,  234, 238, 218]
                #green = [46, 177, 231, 195, 37 ]
                #blue =  [65, 204, 214, 82,  54 ]

                # Viridis                
                red =  [68, 72, 72, 69, 63, 57, 50, 45, 39, 35, 31, 32, 41, 60, 86, 116, 148, 184, 220, 253]
                green = [13, 21, 38, 55, 71, 85, 100, 112, 125, 138, 150, 163, 175, 188, 198, 208, 216, 222, 227, 231]
                blue = [84, 104, 119, 129, 136, 140, 142, 142, 142, 141, 139, 134, 127, 117, 103, 85, 64, 41, 23, 37]

                @N_BINS_PALLETE.times{|bin|
                    m = Sketchup.active_model.materials.add("#{@COLOR_PREFIX}#{bin}")   
                    r = red[bin] 
                    g = green[bin]
                    b = blue[bin]                     
                    m.color=Sketchup::Color.new(r.to_i,g.to_i,b.to_i)
                }                                    
            end

            def self.get_color(v,min,max)
                return Sketchup.active_model.materials["#{@COLOR_PREFIX}0"] if min == max
                return Sketchup.active_model.materials["#{@COLOR_PREFIX}0"] if v <= min
                return Sketchup.active_model.materials["#{@COLOR_PREFIX}#{@N_BINS_PALLETE-1}"] if v >= max

                x = (v - min).to_f/(max-min).to_f                
                bin =  (x/(@BIN_SIZE)).floor
                return Sketchup.active_model.materials["#{@COLOR_PREFIX}#{bin}"]
            end

            # Update the pixel colors of all the solved_workplanes in the model.
			#
			# @author German Molina
			# @param min [Float] the minimum value for the scale
			# @param max [Float] the maximum value for the scale
			# @param metric_name [String] The name of the metric to update
			# @return void
			# @version 0.2
            def self.update_pixel_colors(min,max,metric_name)
                self.add_color_pallete
                
                workplanes=Utilities.get_solved_workplanes()
                workplanes = workplanes.select{|x| JSON.parse(Labeler.get_value(x))["metric"] == metric_name }
                workplanes.each do |workplane|
                    workplane.entities.grep(Sketchup::Face).each do |pixel|                        
                        # now we are sure ent is a pixel.
                        value=Labeler.get_value(pixel)
                        color = get_color( value, min, max)                                    
                        pixel.material = color
                        pixel.back_material = color                        
                    end                   
                    wp_value=JSON.parse(Labeler.get_value(workplane))
                    wp_value["scale_min"]=min
                    wp_value["scale_max"]=max
                    Labeler.set_value(workplane,wp_value.to_json) 
                end
                                
            end


            def self.import_results(path)
                # Check if file exists
                return if not File.exist?(path)
                file = File.read(path)
                results = JSON.parse(file)
                
                workplanes = results["workplanes"]
                summary = results["summary"]
                details = results["details"]
            
                model = Sketchup.active_model
                begin 
                    model.start_operation("import_results",true)
                    
                    # Get all the currently existing solved_workplanes
                    solved_workplanes = Utilities.get_solved_workplanes()

                    # Initialize the script that will update UI
                    script = ""

                    # Iterate all the "details"
                    details.each{|metric_name,values|                        
                        # Absolute minimum and maximum for the metric
                        min = 9999999999999
                        max = -min                        
                    
                        values.each{|wp_name,wp_results|                            
                            #delete previous workplane.
                            solved_workplanes.select{|x|                                                           
                                (not x.deleted? and JSON.parse(Labeler.get_value(x))["metric"] == metric_name)
                            }.select {|x|
                                JSON.parse(Labeler.get_value(x))["workplane"] == wp_name
                            }.each{|x|
                                x.erase!
                            }

                            # Get pixels
                            pixels = workplanes[wp_name]

                            # raise if error
                            raise "Pixels for workplane #{wp_name} are not available" if pixels == nil
                                                                                        
                            # Create a group
                            group = Sketchup.active_model.entities.add_group
                            entities = group.entities

                            pixels.each_with_index{|v,i|
                                v = v.map{|x| x.map{|y| y.m} }        
                                pixel = entities.add_face(v)                                                            
                                Labeler.set_value(pixel,wp_results[i])
                                
                                # Update minimum and maximums
                                max = wp_results[i] if wp_results[i] > max
                                min = wp_results[i] if wp_results[i] < min                                                                
                            }

                            # Hide edges                            
                            entities.grep(Sketchup::Edge).each{|x| x.hidden=true}
                            
                            # Label solved workplane 
                            Labeler.to_solved_workplane(group)
                            Labeler.to_solved_workplane(group.definition)
                            group.casts_shadows=false
                            group.receives_shadows=true

                            # Set value to the workplane
                            wp_value = Hash.new
                            wp_value["metric"] = metric_name
                            wp_value["workplane"] = wp_name
                            wp_value["approved_percentage"] = summary[metric_name][wp_name]
                            wp_value["min"] = min
                            wp_value["max"] = max                            
                            Labeler.set_value(group,wp_value.to_json)

                            # add action to script
                            script += "updateByFields(project_results,['metric','workplane'],['#{metric_name}','#{wp_name}'],{metric: '#{metric_name}', workplane: '#{wp_name}', approved_percentage: #{wp_value["approved_percentage"]}});"
                        }

                        # Update colors for the metric
                        min_max = get_min_max_from_model(metric_name)
                        update_pixel_colors(min,max,metric_name)
                    }             
                    #Update UI                    
                    GH::Groundhog::design_assistant.execute_script(script)

                    model.commit_operation       
                rescue Exception => ex
                    Error.inform_exception(ex)
                    model.abort_operation
                end
                    
            end # end of import_results

            # Checks all the solved workplanes in the model that correspond to a metric
			# and gets the minimum and maximum values from all of them
			#
			# @author German Molina
			# @return [Array<Float>] An array with the minimum and maximum values
			# @param metric_name [String] The name of the objetive that we are getting the min and max from
			# @version 0.2
			def self.get_min_max_from_model(metric_name)
				workplanes = Utilities.get_solved_workplanes()
				#Get the maximum and minimum in the whole model
                min=9999999999999
                max=-min                                
                workplanes.select{|x| 
                    JSON.parse(Labeler.get_value x)["metric"] == metric_name
                }.each do |inst|
					value=JSON.parse(Labeler.get_value(inst))
					min=value["min"] if min > value["min"]
					max=value["max"] if max < value["max"]
				end
				return [min,max]
            end
            
            # Hides all solved workplanes with the exception of those with the input metric
			# @author German Molina
			# @param metric_name [String] The name of the metric to remark
			# @version 0.1
            def self.remark_solved_workplanes(metric_name)
                min=0
                max=0
				#hide them all, except those with the metric we are interested in
				Utilities.get_solved_workplanes().each{|x|
					value=JSON.parse(Labeler.get_value(x))
					if value["metric"] == metric_name then
                        x.hidden = false
                        min = value["scale_min"]
                        max = value["scale_max"]
					else
						x.hidden = true
					end
                }                
                return [min,max]
			end


        end # end module
    end # end module
end # end module