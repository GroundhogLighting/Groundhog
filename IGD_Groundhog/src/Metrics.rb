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
        next "./Results/#{Utilities.fix_name(workplane)}-#{objective["name"]}.txt"
      }

      da[:get_tasks] = Proc.new { |workplane,objective,options|
        next self.calc_annual_illuminance_tasks(workplane)
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
        next "./Results/#{Utilities.fix_name(workplane)}-#{objective["name"]}.txt"
      }

      udi[:get_tasks] = Proc.new { |workplane,objective,options|
        next self.calc_annual_illuminance_tasks(workplane)
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



      ################################################
      ################ END OF LIBARY #################
      ################################################


      # Returns the Proc that returns the tasks corresponding to a certain metric
      # @param metric [String] The metric whose task is needed
      # @author Germán Molina
      # @return [Proc] The required Proc
      def self.get_task(metric)
        return @@library[metric][:get_tasks] unless not @@library.key? metric
        err = "Metric '#{metric}' is not available in the library of metrics"
        UI.messagebox err
        raise err
      end

      # Returns the Proc that returns the read_file corresponding to a certain metric.
      # If the metric does not exist, it raises an error... but if the read_file does
      # does not exist, it returns False, a value understood by other methods.
      # @param metric [String] The metric whose task is needed
      # @author Germán Molina
      # @return [Proc] The required Proc
      def self.get_read_file(metric)
        if not @@library.key? metric then
          err = "Metric '#{metric}' is not available in the library of metrics"
          UI.messagebox err
          raise err
        end
        if not @@library[metric].key? :read_file then
          return false
        end
        return @@library[metric][:read_file]
      end

      # Returns the Proc that returns the write_file corresponding to a certain metric
      # @param metric [String] The metric whose task is needed
      # @author Germán Molina
      # @return [Proc] The required Proc
      def self.get_write_file(metric)
        return @@library[metric][:write_file] unless not @@library.key? metric
        err = "Metric '#{metric}' is not available in the library of metrics"
        UI.messagebox err
        raise err
      end

      # Returns the Proc that returns the calc_score corresponding to a certain metric.
      # If the metric does not exist, it raises an error... but if the calc_score does
      # does not exist, it returns False, a value understood by other methods.
      # @param metric [String] The metric whose task is needed
      # @author Germán Molina
      # @return [Proc] The required Proc
      def self.get_score_calculator(metric)
        if not @@library.key? metric then
          err = "Metric '#{metric}' is not available in the library of metrics"
          UI.messagebox err
          raise err
        end
        if not @@library[metric].key? :calc_score then
          return false
        end
        return @@library[metric][:calc_score]
      end

      # Returns the daylight factor sky String, which is a CIE overcast sky, scaled
      # @author Germán Molina
      # @return [String] The sky definition as a gensky command.
      def self.get_daylight_factor_sky
        return "gensky -ang 45 40 -c -B 0.5586592 -g #{Config.albedo}"
      end

      # Returns the CIE clear sky String
      # @author Germán Molina
      # @param objective [Hash] The objective that contains the date and time for calculating
      # @return [String] The sky definition as a gensky command.
      def self.get_clear_sky(objective)
        albedo = Config.albedo
        date = Date.strptime(objective["date"]["date"], '%m/%d/%Y')
        month = date.month
        day = date.day
        hour = objective["date"]["hour"]
        lat = Sketchup.active_model.shadow_info["Latitude"]
        lon = -Sketchup.active_model.shadow_info["Longitude"]
        mer = -Sketchup.active_model.shadow_info["TZOffset"]
        sky = "gensky #{month} #{day} #{hour} -a #{lat} -o #{lon} -m #{15*mer} -g #{albedo} +s"
      end

      # Return the task corresponding to a full annual climate-based simulation
      # @author Germán Molina
      # @param workplane [String] The name of the workplane whose illuminance we are calculating
      # @return [Task] The task that calculates what we want.
      def self.calc_annual_illuminance_tasks(workplane)
        return DCAnnualIlluminance.new(workplane)
      end

      # Return the task corresponding to a static simulation
      # @author Germán Molina
      # @param target [Hash] A Hash containing the sky and the workplane.
      # @param options [Hash] A Hash containing the simulation options
      # @return [Task] The task that calculates what we want.
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
