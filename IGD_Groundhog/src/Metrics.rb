module IGD
  module Groundhog
    module Metrics

      @@library = Hash.new

      ################################################
      ############# BEGGINNING OF LIBARY #############
      ################################################

      ###### Daylight Autonomy (DA) ######
      da = Hash.new

      da[:read_file] = Proc.new{ |workplane,objective|
        next "./Results/#{Utilities.fix_name(workplane)}-daylight.annual"
      }

      da[:write_file] = Proc.new{ |workplane,objective|
        next "./Results/#{Utilities.fix_name(workplane)}-#{Utilities.fix_name(objective["name"])}.txt"
      }

      da[:get_tasks] = Proc.new { |workplane,objective,options|
        next self.calc_annual_illuminance_tasks(workplane, options)
      }

      da[:calc_score] = Proc.new { |workplane,objective,sensor_working_hours|
        min_lux = objective["good_light"]["min"]
        sensor_good_hours = sensor_working_hours.select{|x| x >= min_lux}
        next (100.0 * sensor_good_hours.length.to_f / sensor_working_hours.length.to_f)
      }

      @@library["DA"] = da


      ###### Usefuld Daylight Illuminance (UDI) ######
      udi = Hash.new

      udi[:read_file] = Proc.new{ |workplane,objective|
        next "./Results/#{Utilities.fix_name(workplane)}-daylight.annual"
      }

      udi[:write_file] = Proc.new{ |workplane,objective|
        next "./Results/#{Utilities.fix_name(workplane)}-#{Utilities.fix_name(objective["name"])}.txt"
      }

      udi[:get_tasks] = Proc.new { |workplane,objective,options|
        next self.calc_annual_illuminance_tasks(workplane, options)
      }

      udi[:calc_score] = Proc.new { |workplane,objective,sensor_working_hours|
        min_lux = objective["good_light"]["min"]
        max_lux = objective["good_light"]["max"]
        sensor_good_hours = sensor_working_hours.select{|x| x >= min_lux and x <= max_lux}
        next (100.0 * sensor_good_hours.length.to_f / sensor_working_hours.length.to_f)
      }

      @@library["UDI"] = udi

      ###### Daylight Factor (DF) ######
      df = Hash.new

      df[:write_file] = Proc.new{ |workplane,objective|
        sky = self.get_daylight_factor_sky
        next "./Results/#{Utilities.fix_name(workplane)}-#{Utilities.fix_name(sky)}.txt"
      }

      df[:get_tasks] = Proc.new { |workplane,objective,options|
        sky = self.get_daylight_factor_sky
        target = {"workplane" =>workplane, "sky" => sky}
        next self.calc_static_illuminance_tasks(target,options)
      }

      @@library["DF"] = df

      ###### Illuminance at a certain time (LUX) ######
      lux = Hash.new

      lux[:write_file] = Proc.new{ |workplane,objective|
        sky = self.get_clear_sky(objective)
        next "./Results/#{Utilities.fix_name(workplane)}-#{Utilities.fix_name(sky)}.txt"
      }

      lux[:get_tasks] = Proc.new { |workplane,objective,options|
        sky = self.get_clear_sky(objective)
        target = {"workplane" =>workplane, "sky" => sky}
        self.calc_static_illuminance_tasks(target,options)
      }

      @@library["LUX"] = lux


      ###### SKY VISIBILITY (SKY_VISIBILITY) ######
      sky_visibility = Hash.new

      sky_visibility[:write_file] = Proc.new{ |workplane,objective|
        sky = self.get_daylight_factor_sky
        next "./Results/#{Utilities.fix_name(workplane)}-sky_visibility.txt"
      }

      sky_visibility[:read_file] = Proc.new{ |workplane,objective|
        sky = self.get_daylight_factor_sky
        next "./Results/#{Utilities.fix_name(workplane)}-sky_visibility.txt"
      }

      sky_visibility[:get_tasks] = Proc.new { |workplane,objective,options|
        next SkyVisibility.new(workplane)
      }

      sky_visibility[:calc_score] = Proc.new{|sensor_value|
        if sensor_value > 0 then
          next 1
        else
          next 0
        end
      }

      @@library["SKY_VISIBILITY"] = sky_visibility

      ###### LEED EQc7 opt2 (LEED_EQc7_opt2) ######
      leed_eqc7_opt2 = Hash.new

      leed_eqc7_opt2[:write_file] = Proc.new{ |workplane,objective|
        sky = self.get_equinox_sky(objective)
        next "./Results/#{Utilities.fix_name(workplane)}-#{Utilities.fix_name(sky)}.txt"
      }

      leed_eqc7_opt2[:get_tasks] = Proc.new { |workplane,objective,options|
        sky = self.get_equinox_sky(objective)
        target = {"workplane" =>workplane, "sky" => sky}
        next self.calc_static_illuminance_tasks(target,options)
      }

      @@library["LEED_EQc7_opt2"] = leed_eqc7_opt2

      ################################################
      ################ END OF LIBARY #################
      ################################################

      # Gets the Proc that returns the tasks necessary to calculate a certain metric.
      #
      # @param metric [String] The name of the metric
      # @return [Proc] The proc
      def self.get_task(metric)
        return @@library[metric][:get_tasks] unless not @@library.key? metric
        UI.messagebox "Metric '#{metric}' is not available in the library of metrics"
      end

      # Gets the Proc that returns the read_file of a certain metric.
      # That is, the Proc that returns the name of the  file that needs to be
      # read, processed (using the :calc_score Proc), for lately write the write_file.
      #
      # @param metric [String] The name of the metric
      # @return [Proc] The proc
      # @note If the :read_file key is not available, it will return False, which is not an error and will be understood by other methods.
      def self.get_read_file(metric)
        if not @@library.key? metric then
          UI.messagebox "Metric '#{metric}' is not available in the library of metrics"
          return false
        end
        if not @@library[metric].key? :read_file then
          return false
        end
        return @@library[metric][:read_file]
      end

      # Gets the Proc that returns the write_file of a certain metric.
      # That is, the final file whose results will be imported as pixels.
      #
      # @param metric [String] The name of the metric
      # @return [Proc] The proc
      def self.get_write_file(metric)
        return @@library[metric][:write_file] unless not @@library.key? metric
        UI.messagebox "Metric '#{metric}' is not available in the library of metrics"
      end

      # Gets the Proc that returns the calc_score of a certain metric.
      # That is, the Proc that will trasform the read_file into the write_file.
      #
      # @param metric [String] The name of the metric
      # @return [Proc] The proc
      # @note If the :calc_score key is not available, it will return False, which is not an error and will be understood by other methods.
      def self.get_score_calculator(metric)
        if not @@library.key? metric then
          UI.messagebox "Metric '#{metric}' is not available in the library of metrics"
          return false
        end
        if not @@library[metric].key? :calc_score then
          return false
        end
        return @@library[metric][:calc_score]
      end

      # Returns the sky used for calculating the daylight factor.
      # @author Germán Molina
      # @return [String] The sky definition as a gensky command
      def self.get_daylight_factor_sky
        return "gensky -ang 45 40 -c -B 0.5586592 -g #{Config.albedo}"
      end

      # Returns the CIE clear sky corresponding to a certain objective.
      #
      # @param objective [Hash] The objective in Hash format
      # @author Germán Molina
      # @return [String] The sky definition as a gensky command
      def self.get_clear_sky(objective)
        albedo = Config.albedo
        date = Date.strptime(objective["date"]["date"], '%m/%d/%Y')
        month = date.month
        day = date.day
        hour = objective["date"]["hour"]
        lat = Sketchup.active_model.shadow_info["Latitude"]
        lon = -Sketchup.active_model.shadow_info["Longitude"]
        mer = -Sketchup.active_model.shadow_info["TZOffset"]
        "gensky #{month} #{day} #{hour} -a #{lat} -o #{lon} -m #{15*mer} -g #{albedo} +s"
      end

      # Returns the Perez clearest sky corresponding to an equinox objective.
      #
      # @param objective [Hash] The objective in Hash format
      # @author Adrià González-Esteve
      # @return [String] The sky definition as a gendaylit command
      def self.get_equinox_sky(objective)
        objective["date"]["date"]  = "3/21/2018"
        day = 21
        hour = objective["date"]["hour"]

        Sketchup.active_model.shadow_info["ShadowTime"] = Time.new(2018, 3, 21, hour, 0, 0,"+01:00")
        sun = Sketchup.active_model.shadow_info["SunDirection"]
        zenith = sun.angle_between(Geom::Vector3d.new(0,0,1)).radians
        zenith_coefficient = 1.041*zenith**3

        objective["irradiance"] = {"global_horizontal" => 0.0, "diffuse_horizontal" => 0.0}
        [3,9].each do |month|
          weather = JSON.parse(Sketchup.active_model.get_attribute("Groundhog","Weather"))
          weather_data = weather["data"]
          prev_index = weather_data.index do |x| x["month"]==month && x["day"]==day && x["hour"]==hour-0.5 end
          prev_fortnight_data = (-7..7).to_a.map do |x| weather_data[x*24+prev_index] end
          next_index = weather_data.index do |x| x["month"]==month && x["day"]==day && x["hour"]==hour+0.5 end
          next_fortnight_data = (-7..7).to_a.map do |x| weather_data[x*24+next_index] end
          fortnight_data = []
          prev_fortnight_data.zip(next_fortnight_data).each do |prev_data, next_data|
            data = Hash.new
            data["global_horizontal"] = 0.5*(prev_data["global_horizontal"].to_f+next_data["global_horizontal"].to_f)
            data["direct_normal"] = 0.5*(prev_data["direct_normal"].to_f+next_data["direct_normal"].to_f)
            data["diffuse_horizontal"] = 0.5*(prev_data["diffuse_horizontal"].to_f+next_data["diffuse_horizontal"].to_f)
            fortnight_data << data
          end
          clearness_epsilons = fortnight_data.map do |x| ((x["diffuse_horizontal"]+x["direct_normal"])/x["diffuse_horizontal"]+zenith_coefficient)/(1+zenith_coefficient) end
          index = clearness_epsilons.each_with_index.max.last
          objective["irradiance"]["global_horizontal"] += fortnight_data[index]["global_horizontal"]
          objective["irradiance"]["diffuse_horizontal"] += fortnight_data[index]["diffuse_horizontal"]
        end
        objective["irradiance"]["global_horizontal"] *= 0.5
        objective["irradiance"]["diffuse_horizontal"] *= 0.5
        Objectives.create_objective(objective)

        return self.get_sky_irradiance(objective)
      end

      # Returns the Perez sky corresponding to a certain objective for diffuse and direct components.
      #
      # @param objective [Hash] The objective in Hash format
      # @author Adrià González-Esteve
      # @return [String] The sky definition as a gendaylit command
      def self.get_sky_irradiance(objective)
        albedo = Config.albedo

        date = Date.strptime(objective["date"]["date"], '%m/%d/%Y')
        month = date.month
        day = date.day
        hour = objective["date"]["hour"]

        lat = Sketchup.active_model.shadow_info["Latitude"]
        lon = -Sketchup.active_model.shadow_info["Longitude"]
        mer = -Sketchup.active_model.shadow_info["TZOffset"]

        global_horizontal = objective["irradiance"]["global_horizontal"]
        diffuse_horizontal = objective["irradiance"]["diffuse_horizontal"]

        "gendaylit #{month} #{day} #{hour} -G #{global_horizontal-diffuse_horizontal} #{diffuse_horizontal} -a #{lat} -o #{lon} -m #{15*mer} -g #{albedo}"
      end

      # Returns the Task that calculates annual illuminance values according to the
      # input weather file.
      #
      # @param workplane [String] The name of the workplane
      # @param options [Hash] The options of the Simulation manager (for choosing methods)
      # @author Germán Molina
      # @return [Task] The task
      def self.calc_annual_illuminance_tasks(workplane, options)
        return DCAnnualIlluminance.new(workplane)
      end

      # Returns the Task that calculates illuminance in a static moment of the year
      #
      # @param target [Hash] A hash containing the sky at the moment and the workplane
      # @param options [Hash] The options of the Simulation manager (for choosing methods)
      # @author Germán Molina
      # @return [Task] The task
      def self.calc_static_illuminance_tasks(target,options)
        case options["static_calculation_method"]
        when "RTRACE"
            return RtraceInstantIlluminance.new(target)
        when "DC"
            return DCInstantIlluminance.new(target)
        else
            raise "Unkown illuminance tasks for #{options["static_calculation_method"]} calculation method"
        end
      end

    end
  end
end
