module IGD
  module Groundhog
    module TDD

      @lens_default_mat = "void light default_tdd_lens_mat 0 0 3 1 1 1"#"void glass default_tdd_lens_mat\n0\n0\n3\t0\t0\t0\n\n"
      @pipe_default_mat = "void metal default_tdd_pipe_mat\n0\n0\n5\t0.98\t0.98\t0.98\t0.99\t0\n\n"


      # Returns the lens default material
      # @author German Molina
      # @version 0.1
      # @return [String] The material definition
      def self.lens_material
        @lens_default_mat
      end

      # Returns the lens default material
      # @author German Molina
      # @version 0.1
      # @return [String] The material definition
      def self.pipe_material
        @pipe_default_mat
      end


      # Export the Tubular Daylight Devices into separate files, separating
      #   the Pipe, the Upper Lens and the Lower Lens.
      # @author German Molina
      # @version 0.1
      # @param path [String] Directory where the Component Definitions are located
      # @param tdd [Boolean] The Tubular Daylight Device component definition
      # @return [String] The string that should be written in the Component Definition file.
      def self.write_tdd(path,tdd)
        path = "#{path}/pieces"
        geom = ""
        #mat_array = []
        name=Utilities.fix_name(tdd.name)
        pipe_filename = "#{name}_pipe.rad"
        top_filename = "#{name}_top_lens.rad"
        bottom_filename = "#{name}_bottom_lens.rad"

        #create the dir, if it does not exist
        OS.mkdir(path)
        entities=tdd.entities
        faces=Utilities.get_faces(entities)
        instances=Utilities.get_component_instances(entities)

        n_top_lens = faces.select{|x| Labeler.tdd_top? x}.length
        n_bottom_lens = faces.select{|x| Labeler.tdd_bottom? x}.length


        if n_top_lens != 1 or n_bottom_lens != 1 then
          UI.messagebox "Incorrect definition of TDD #{name}.\n\nIt will be ignored."
          return false
        end

        UI.messagebox "There are components inside a Tubular Daylight Device! They will be ignored" if instances.length > 0

        faces.each{|face|
          info=Exporter.get_rad_string(face)
          if Labeler.tdd_top?(face) then
            info = Exporter.get_reversed_rad_string(face) if face.normal.z > 0
            File.open("#{path}/#{bottom_filename}",'w'){|top|
              top.write "\#@rfluxmtx h=kf u=Y\n\n#{self.lens_material}\n\n default_tdd_lens_mat #{info[0]}"
            }
          elsif Labeler.tdd_bottom?(face) then
            info = Exporter.get_reversed_rad_string(face) if face.normal.z > 0
            File.open("#{path}/#{top_filename}",'w'){|top|
              top.write "\#@rfluxmtx h=kf u=Y\n\n#{self.lens_material}\n\n default_tdd_lens_mat #{info[0]}"
            }
          else
            geom = geom + "default_tdd_pipe_mat" + info[0]
          end
        }
        File.open("#{path}/#{pipe_filename}",'w'){|pipe|
          pipe.write "#{self.pipe_material}\n\n#{geom}"
        }

        return "!xform ./pieces/#{pipe_filename}\n!xform ./pieces/#{top_filename}\n!xform ./pieces/#{bottom_filename}\n"
      end


    end
  end
end
