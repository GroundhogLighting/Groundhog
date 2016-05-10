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
        OS.mkdir(path)
        #path = "#{path}/Pieces"
        geom = ""

        name=Utilities.fix_name(tdd.name)
        pipe_filename = "#{name}.pipe"
        top_filename = "#{name}.top"
        bottom_filename = "#{name}.bottom"

        faces=Utilities.get_faces(tdd.entities)
        n_top_lens = faces.select{|x| Labeler.tdd_top? x}.length
        n_bottom_lens = faces.select{|x| Labeler.tdd_bottom? x}.length

        tr = Utilities.get_all_global_transformations(faces[0],Geom::Transformation.new)
        if n_top_lens != 1 or n_bottom_lens != 1 then
          UI.messagebox "Incorrect definition of TDD #{name}.\n\nIt will be ignored."
          return false
        end

        #OS.mkdir(path) #make the Pieces path

        tr.each_with_index{|t,index|
          #File.open("#{path}/#{index}_#{name}.rad",'w'){ |file|

            faces.each{|face|
              info = Exporter.get_transformed_rad_string(face,t)
              if Labeler.tdd_top?(face) then
                #info = Exporter.get_reversed_transformed_rad_string(face,t) if face.normal.z > 0
                File.open("#{path}/#{index}_#{bottom_filename}",'w'){|top|
                  top.write "\#@rfluxmtx h=kf u=Y\n\n#{self.lens_material}\n\n default_tdd_lens_mat #{info[0]}"
                }
              elsif Labeler.tdd_bottom?(face) then
                #info = Exporter.get_reversed_transformed_rad_string(face,t) if face.normal.z > 0
                File.open("#{path}/#{index}_#{top_filename}",'w'){|top|
                  top.write "\#@rfluxmtx h=kf u=Y\n\n#{self.lens_material}\n\n default_tdd_lens_mat #{info[0]}"
                }
              else
                geom = geom + "default_tdd_pipe_mat" + info[0]
              end
            }
            File.open("#{path}/#{index}_#{pipe_filename}",'w'){|pipe|
              pipe.write "#{self.pipe_material}\n\n#{geom}"
            }


            #file.write("\#xform ")
          #}
        }

        return true
      end


    end
  end
end
