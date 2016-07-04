module IGD
    module Groundhog

        class Range
            attr_reader :min, :max
            # we expect a text in "min-max" format or just "min"
            def initialize(text)
                min_max = text.split("-")                
                @min = min_max[0].to_f
                @max = min_max[1].to_f if min_max[1]
            end
        end


        class Objective

            attr_reader :calc, :goal, :dynamic, :metric, :light_range, :time_range, :date, :sim_period, :hour, :working_time
            
            def initialize(text)
                data = text.split(" | ")
                main_info = data.shift

                @calc = main_info.split("(")[0]
                @dynamic = false                
                case @calc
                when "LUX"
                    @light_range = Range.new main_info.tr("#{@calc}()lux","")
                    fecha = data.shift
                    @metric = "LUX(#{fecha})"
                    @hour = fecha.split("hrs of ")[0].to_f
                    fecha = fecha.split("hrs of ")[1]                    
                    @date = Date.strptime(fecha,"%m/%d/%Y")                    
                when "DF"
                    @light_range = Range.new main_info.tr("#{@calc}()%","")
                    @metric = "DF"
                when "DA"
                    ranges =  main_info.tr("#{@calc}()lux","")                    
                    @light_range = Range.new ranges.split(",").shift
                    @time_range = Range.new ranges.split(",").pop
                    months = data.shift                    
                    @working_time = Range.new data.shift.gsub("Working from","").gsub("to","-")
                    @dynamic = true
                    @metric="DA(#{@light_range.min.to_i}lux)"                    
                when "UDI"
                    ranges =  main_info.tr("#{@calc}()lux","")                    
                    @light_range = Range.new ranges.split(",").shift
                    @time_range = Range.new ranges.split(",").pop
                    months = data.shift                    
                    @working_time = Range.new data.shift.gsub("Working from","").gsub("to","-")           
                    @dynamic=true
                    @metric="UDI(#{@light_range.min.to_i},#{@light_range.max.to_i}lux)"
                end                
                @goal = data.pop.tr("%","").to_f

            end

        end
    end
end