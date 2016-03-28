module IGD
    module Groundhog
        module Lamps

            # Compares two numbers.
            #
            #  This is a function present within Radiance's code that I just replicated.
            # @author German Molina based on Radiance's code
            # @param a [<float>] a number to compare
            # @param b [<float>] the other number to compare
            # @return [Boolean] Boolean representing if the numbers are similar or not.
            def self.feq(a,b)
                ftny = 1e-6
                return (a<=b+ftny  and a>=b-ftny)
            end

            @lamp_table = {
                /deluxe warm white/	=>	[0.440, 0.403, 0.85],
                /warm white deluxe/	=> [0.440, 0.403, 0.85],
                /deluxe cool white/ => [0.376, 0.368, 0.85],
                /cool white deluxe/ => [0.376, 0.368, 0.85],
                /warm[- ]white/	=> [0.436, 0.406, 0.85],
                /cool[- ]white/=> [0.373, 0.385, 0.85],
                /white\>.*\<fluor/ => [0.41, 0.398, 0.85],
                /daylight\>.*\<fluor/=> [0.316, 0.345, 0.85],
                /clear mercury/ => [0.326, 0.39, 0.8],
                /phosphor\>.*\<mercury/ => [0.373, 0.415, 0.8],
                /mercury\>.*\<phosphor/ => [0.373, 0.415, 0.8],
                /mercury/ => [0.326, 0.39, 0.8],
                /clear metal halide/ => [0.396, 0.390, 0.8],
                /metal halide/ => [0.396, 0.390, 0.8],
                /xenon/ => [0.324, 0.324, 1],
                /high[- ]pressure\>.*\<sodium/ => [0.519, 0.418, 0.9],
                /low[- ]pressure\>.*\<sodium/ => [0.569, 0.421, 0.93],
                /sodium/ => [0.569, 0.421, 0.93],
                /halogen/ => [0.424, 0.399, 1],
                /quartz/ => [0.424, 0.399, 1],
                /incandescent/ => [0.453, 0.405, 0.95],
                /\<incand/ => [0.453, 0.405, 0.95],
                /fluorescent/ => [0.373, 0.385, 0.85],
                /\<fluor/ => [0.373, 0.385, 0.85],
                /\<spot\>/ => [0.453, 0.405, 0.95],
                /\<flood\>/ => [0.453, 0.405, 0.95],
                /headlamp/ => [0.453, 0.405, 0.95],
                /headlight/ => [0.453, 0.405, 0.95],
                /phosphor[- ]coated HID\>/ => [0.373, 0.415, 0.8],
                /diffuse\>.*\<HID\>/ => [0.519, 0.418, 0.9],
                /frosted\>.*\<HID\>/ => [0.519, 0.418, 0.9],
                /HPS/ => [0.519, 0.418, 0.9],
                /\<LPS/ => [0.569, 0.421, 0.93],
                /\<[EP]AR\>/ => [0.453, 0.405, 0.95],
                /ER30/ => [0.453, 0.405, 0.95],
                /\<D65WHITE\>/ => [0.313, 0.329, 1],
                /\<WHITE\>/ => [0.3333, 0.3333, 1],
                /\<MH\>/ => [0.396, 0.390, 0.8],
                /\<clear HID\>/ => [0.519, 0.418, 0.9],
                /\<HID\>/ => [0.519, 0.418, 0.9]
            }

            def self.match_lamp(lamp)
                @lamp_table.each do |l|
                    if lamp=~ l[0] then #if it matches
                        return l[1]
                    end
                    return [1.0/3.0, 1.0/3.0, 1.0] #if not found
                end
            end


            def self.get_illum_shape(definition)
                ret = Hash.new()

                threshold = 2.0

                bounds = definition.bounds
                max = bounds.max
                min = bounds.min

                size = [max[0]-min[0],max[1]-min[1],max[2]-min[2]]
                ret["center"] = [(max[0]+min[0])/2.0,(max[1]+min[1])/2.0,(max[2]+min[2])/2.0]
                ret["center"] = ret["center"].map{|i| i.to_m}


                aspect = size.max/size.min

                if aspect <= Config.luminaire_shape_threshold then
                    ret["shape"] = "sphere"
                    ret["radius"] = bounds.diagonal.to_m*0.5
                else #box
                    ret["shape"] = "box"
                    ret["xdim"] = size[0].to_m+0.005
                    ret["ydim"] = size[1].to_m+0.005
                    ret["zdim"] = size[2].to_m+0.005
                end

                return ret
            end


            def self.ies2rad(iesname, multiplier, definition, path)

                ret = []

                ret << "### BEGINNING OF IES2RAD OUTPUT\n\n"

                name = Utilities.fix_name(definition.name)

                #abort if file is not found
                warn "input file does not exist" if not File.exist? iesname
                return false if not File.exist? iesname

                ### PUT HEADER
                ret << "# rad file generated within Groundhog using code based on RADIANCE's IES2RAD program"
                ret << "# Dimensions in meters"

                text=File.open(iesname).read.gsub!(/\r\n?/, "\n").split("\n")

                lamptype = ""
                while text.length > 0 do
                    lamptype = text[0].tr("[LAMP]","") if text[0].start_with? "[LAMP]"
                    ret <<  "#<#{text.shift}"
                    break if text[0].start_with? "TILT="
                end

                x,y,depreciation = match_lamp(lamptype)


                ret <<  "# CIE(x,y) = (#{x},#{y})\n# Depreciation = #{100.0*depreciation}%"


                #WE STILL DO NOT SUPPORT TILT
                tilt = text.shift.split("=")[1]
                if tilt != "NONE" then
                    UI.messagebox "\n\n SORRY: TILT is not yet supported... Your luminaire has TILT=#{tilt}\n\n"
                    return false

                    ### SKIP ALL THIS... WILL INCLUDE PROCESSING SOON
                    text.shift #lamp to luminaire is absent if tilt=NONE
                    text.shift #<# of pairs of angles and multiplying factors> is absent if tilt = NONE
                    text.shift #tilt angles also absent
                    text.shift #multiplying factors
                end

                #analyze IES file information
                aux = text.shift.split(" ")
                warn "incorrect IES file" if aux.length != 10
                return false if aux.length != 10
                n_lamps,lumen_per_lamp,mult,vang,hang,pmtype,untype,width,length,height = aux.flatten.collect { |i| i.to_f }

                aux = text.shift.split(" ")
                warn "incorrect IES file" if aux.length != 3
                return false if aux.length != 3
                bfactor,pfactor,watts = aux.flatten.collect { |i| i.to_f }

                warn "unsupported photometric type #{pmtype}" if pmtype != 1 and pmtype!=2
                return false if pmtype != 1 and pmtype!=2


                mult = multiplier*mult*bfactor*pfactor;
                warn "too few measured angles" if vang< 2 or hang < 1
                return false  if vang< 2 or hang < 1

                if(untype == 1) then #it is in feet
                    width*=0.3048
                    length*=0.3048
                    height*=0.3048
                end


                # WRITE THE DAT FILE
                OS.mkdir("#{path}/dat")

                datname = name+".dat"
                bounds = self.write_dat_file(vang,hang,"#{path}/dat/"+datname,text)

                warn "error writing dat file" if not bounds
                return false if not bounds


                ret << "# #{watts} watt luminaire, lamp*ballast factor = #{bfactor*pfactor}"
                ret << "\nvoid brightdata #{name}_dist"

                nargs = ""
                if (hang < 2)
                    nargs = "4"
                elsif (pmtype == 2)
                    nargs = "5"
                elsif (self.feq(bounds[1][0],90.0) && self.feq(bounds[1][1],270.0))
                   nargs = "7"
                else
                    nargs = "5"
                end

                illum = self.get_illum_shape(definition)


                source_arg = "corr"
                if illum["shape"] == "box" then #only allow box and sphere
                    source_arg = "boxcorr"
                end

                nargs += " #{source_arg} ./Components/dat/#{datname} source.cal "

                if pmtype == 2 then
            		if (self.feq(bounds[1][0],0.0))
            			nargs += "srcB_horiz2 "
            		else
            			nargs += "srcB_horiz "
                    end
                    nargs += "srcB_vert "
            	else # pmtype == PM_C
                    if hang >= 2 then
                        d1 = bounds[1][1] - bounds[1][0];
                        if (d1 <= 90.0+1e-6)
                            nargs +="src_phi4 "
                        elsif (d1 <= 180.0+1e-6) then
                            if (self.feq(bounds[1][0],90.0))
                                fnargs +="src_phi2+90 "
                            else
                                nargs +="src_phi2 "
                            end
                        else
                            nargs +="src_phi "
                        end
                        nargs +="src_theta "

                        nargs +="-rz -90 " if (self.feq(bounds[1][0],90.0) && self.feq(bounds[1][1],270.0))

                    else
                        nargs +="src_theta "
                    end
            	end

                ret << nargs

                if illum["shape"] == "sphere" then
                    area = 3.141592654*illum["radius"]*illum["radius"]
                    ret << "0\n1 #{mult/area}\n"
                else #box
                    ret << "0\n4 #{multiplier} #{illum["xdim"]} #{illum["ydim"]} #{illum["zdim"]}"
                end

                ret << "#{name}_dist illum #{name}_light"

                # convert xyY to XYZ
                xyz=[]
                xyz[1] = depreciation
                xyz[0] = x*depreciation/y #xy[0]/xyz[1] * xyz[1];
                xyz[2] = (1-x-y)*depreciation/y #xyz[1]*(1.0/xy[1] - 1.0) - xyz[0]

                color = Color.cie2rgb(xyz)

                ret << "0\n0\n3 #{color[0]} #{color[1]} #{color[2]}\n"

                if illum["shape"] == "sphere" then
                    ret << "#{name}_light sphere #{name}.s"
                    ret << "0\n0\n4 #{illum["center"][0]} #{illum["center"][1]} #{illum["center"][2]} #{illum["radius"]}"
                else
                    #orc= [illum["xdim"]/2.0, illum["ydim"]/2.0, illum["zdim"]/2.0]
                    t = [illum["center"][0]-illum["xdim"]/2.0,illum["center"][1]-illum["ydim"]/2.0,illum["center"][2]-illum["zdim"]/2.0]
                    ret << "!genbox #{name}_light #{name} #{illum["xdim"]} #{illum["ydim"]} #{illum["zdim"]} | xform -t #{t[0]} #{t[1]} #{t[2]}"
                end

                ret << "### END OF IES2RAD OUTPUT\n\n"

                return ret.join("\n")
            end



            def self.write_dat_file(vang,hang,iesname, ies_content)

                total = 1
                j = 0
                npts = [vang,hang]
                for i in [0,1] do
                    if (npts[i] > 1) then
                        total *= npts[i]
                        j+=1
                    end
                end

                dat = File.open(iesname,'w')
                dat.puts j

                #now we analize by number
                ies_content =  ies_content.join(" ").split(" ")


                vpts = []
                vang.to_i.times do
                    vpts << ies_content.shift.to_f
                end
                hpts = []
                hang.to_i.times do
                    hpts << ies_content.shift.to_f
                end

                vlim = [vpts[0],vpts[vpts.length-1]]
                hlim = [hpts[0],hpts[hpts.length-1]]

                pt=[vpts,hpts]

                # Write in REVERSE order
                for i in [1,0] do
                   if (npts[i] > 1) then
                        for j in 1..npts[i]-2 do
                            break if not self.feq(pt[i][j]-pt[i][j-1],pt[i][j+1]-pt[i][j])
                        end
                        j = npts[i]-1 ### CHANGE THIS
                        if j == npts[i]-1 then
                            dat.puts "#{pt[i][0].to_i} #{pt[i][j].to_i} #{npts[i].to_i}"
                        else
                            dat.puts "0 0 #{npts[i].to_i}"
                            for j in 0..npts[i] do
                                if (j%4 == 0) then
                                    dat.write "\n"
                                end
                                dat.write "\t#{pt[i][j]}"
                            end
                        end
                    end
                end

                for i in 0..total do
                    if (i%4 == 0) then
                        dat.write "\n"
                    end
                    val = ies_content.shift.to_f
                    warn "FATAL: Unexpected end of file" if val == nil
                    return false if val == nil
                    dat.write "\t#{val/179.0} "

                end

                dat.close()

                return [vlim,hlim]

            end #end function
        end
    end
end
