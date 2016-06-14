
module IGD
  module Groundhog
    module Weather

      # Reads an EPW file and returns a HASH containing the weather
      # with the structure needed by Groundhog
      # @author German Molina
      # @param epw [String] the path to the EPW file
      # @return [Hash] The weather in the format that Groundhog Likes
      def self.parse_epw(epw)
        weather = Hash.new
        lines = File.readlines(epw)
        location_data = lines.shift.split(",")
        location_data.shift

        weather["city"] = location_data.shift
        weather["state"] = location_data.shift
        weather["country"] = location_data.shift
        data_source = location_data.shift
        wmo_number = location_data.shift
        weather["latitude"] = location_data.shift.to_f
        weather["longitude"] = location_data.shift.to_f
        weather["timezone"] = location_data.shift.to_i
        weather["elevation"] = location_data.shift.to_f
        weather["data"] = []

        7.times{lines.shift}
        lines.each{|line|
          data = line.split(",")
          month = data[1].to_i
          day = data[2].to_i
          hour = data[3].to_f
          direct = data[14]
          diffuse = data[15]
          weather["data"] << {"month" => month, "day" => day, "hour" => (hour-0.5), "direct_normal" => direct, "diffuse_horizontal" => diffuse}
        }

        return weather
      end

      # Writes a WEA weather tape from a HASH that represents the weather within
      #  Groundhog. It allows writing incomplete weather files, thinking on
      #  performing simulations of periods of the year.
      # @author German Molina
      # @param weather [Hash] The Hash to transform in WEA file
      # @param month_ini [Integer] The first month to write
      # @param month_end [Integer] The last month to write
      # @param destination [String] The directory where the file will be written
      # @return [Hash] The weather in the format that Groundhog Likes
      def self.write_wea(weather, month_ini, month_end, destination)
        File.open(destination,'w'){|file|
          if month_end < month_ini then
            warn "Inconsistent initial and end months!"
            return false
          end
          file.puts "place #{weather["city"]}_#{weather["country"]}"
          file.puts "latitude #{weather["latitude"]}"
          file.puts "longitude #{-weather["longitude"]}"
          file.puts "time_zone #{-15*weather["timezone"]}"
          file.puts "site_elevation #{weather["elevation"]}"
          file.puts "weather_data_file_units 1"
          weather["data"].each{|value|
            next if  value["month"] < month_ini
            break if value["month"] > month_end
            file.puts "#{value["month"]} #{value["day"]} #{value["hour"]} #{value["direct_normal"]} #{value["diffuse_horizontal"]}"
          }
        }
        return true
      end



    end
  end
end
