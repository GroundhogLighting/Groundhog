module IGD
  module Groundhog
    module TDD



      # Returns the lens default material
      # @author German Molina
      # @version 0.1
      # @return [String] The material definition
      def self.lens_material(name)
        "void light #{name} 0 0 3 1 1 1"
      end

      # Returns the lens default material
      # @author German Molina
      # @version 0.1
      # @return [String] The material definition
      def self.pipe_material
        r = Config.tdd_pipe_reflectance
        "void metal default_tdd_pipe_mat\n0\n0\n5\t#{r}\t#{r}\t#{r}\t1\t0\n\n"
      end


      # Export the Tubular Daylight Devices into separate files, separating
      #   the Pipe, the Upper Lens and the Lower Lens.
      # @author German Molina
      # @version 0.1
      # @param path [String] Directory where the Component Definitions are located
      # @param tdd [Boolean] The Tubular Daylight Device component definition
      # @return [String] The string that should be written in the Component Definition file.
      def self.write_tdd(path,tdd)
        OS.mkdir(path)
        geom = ""

        name=Utilities.fix_name(tdd.name)
        pipe_filename = "#{name}.pipe"
        top_filename = "#{name}.top"
        bottom_filename = "#{name}.bottom"
        top_lens_bsdf = "#{name}_top.xml"
        bottom_lens_bsdf = "#{name}_bottom.xml"

        faces=Utilities.get_faces(tdd.entities)
        top_lens = faces.select{|x| Labeler.tdd_top? x}
        bottom_lens = faces.select{|x| Labeler.tdd_bottom? x}
        n_top_lens = top_lens.length
        n_bottom_lens = bottom_lens.length

        if n_top_lens != 1 or n_bottom_lens != 1 then
          UI.messagebox "Incorrect definition of TDD #{name}.\n\nIt will be ignored."
          return false
        end

        #Write BSDFs
        File.open("#{path}/#{top_lens_bsdf}",'w'){|top|
          Labeler.get_value(top_lens[0]).each{ |line|
            top.puts line
          }
        }
        File.open("#{path}/#{bottom_lens_bsdf}",'w'){|bottom|
          Labeler.get_value(bottom_lens[0]).each{ |line|
            bottom.puts line
          }
        }

        # Write all the instances
        tr = Utilities.get_all_global_transformations(faces[0],Geom::Transformation.new)
        tr.each_with_index{|t,index|
            faces.each{|face|
              info = Exporter.get_transformed_rad_string(face,t,"#{Labeler.get_fixed_name(face)}_#{index}")
              if Labeler.tdd_top?(face) then
                #info = Exporter.get_reversed_transformed_rad_string(face,t,"#{Labeler.get_fixed_name(face)}_#{index}") if face.normal.z > 0
                File.open("#{path}/#{index}-#{top_filename}",'w'){|top|
                  mat_name = "lens_mat"
                  top.write "\#@rfluxmtx h=kf u=Y\n\n#{self.lens_material(mat_name)}\n\n #{mat_name} #{info[0]}"
                }
              elsif Labeler.tdd_bottom?(face) then
                #info = Exporter.get_reversed_transformed_rad_string(face,t,"#{Labeler.get_fixed_name(face)}_#{index}") if face.normal.z > 0
                File.open("#{path}/#{index}-#{bottom_filename}",'w'){|bottom|
                  mat_name = "#{name}_#{index}_mat"
                  bottom.write "#{self.lens_material(mat_name)}\n\n #{mat_name} #{info[0]}"
                }
              else
                geom = geom + "default_tdd_pipe_mat" + info[0]
              end
            }
            File.open("#{path}/#{index}-#{pipe_filename}",'w'){|pipe|
              pipe.write "#{self.pipe_material}\n\n#{geom}"
            }

        }

        return true
      end


    end
  end
end
