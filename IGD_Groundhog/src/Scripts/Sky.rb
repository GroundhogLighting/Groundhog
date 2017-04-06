module IGD
    module Groundhog

        #Writes the white sky
        class WriteWhiteSky < Task
            def initialize
                @proc = Proc.new { |options|
                    n_bins = options["sky_bins"]
                    File.open("./Skies/white_sky.rad",'w'){|f| f.puts "\#@rfluxmtx h=u u=Y\nvoid glow ground_glow\n0\n0\n4 1 1 1 0\n\nground_glow source ground\n0\n0\n4 0 0 -1 180\n\n\#@rfluxmtx h=r#{n_bins} u=Y\nvoid glow sky_glow\n0\n0\n4 1 1 1 0\n\nsky_glow source sky\n0\n0\n4 0 0 1 180" }
                    next [] #does not return any script... just writes file
                }                
            end           
        end

        class WriteSky < Task
            def initialize(sky)                                
                @target = sky                
                @proc = Proc.new{
                    fix_sky = Utilities.fix_name(@target)                    
                    File.open("./Skies/#{fix_sky}.rad",'w'){|file|
                        file.puts "!#{ @target}"
                        file.puts "skyfunc glow skyglow 0 0 4 0.99 0.99 1.1 0"
                        file.puts "skyglow source skyball 0 0 4 0 0 1 360"
                    }
                    next []
                }
            end
        end

        class GenDayMtx < Task
            def initialize 
                @proc = Proc.new{ |options|
                    albedo = Config.albedo
                    mf = options["sky_bins"] 
                    if not File.file? "./Skies/weather.wea" then
                        UI.messagebox("This model has no Weather File assigned... please select one that.")
                        next false
                    end
                    next ["gendaymtx -m #{mf} -g #{albedo} #{albedo} #{albedo} ./Skies/weather.wea > ./Skies/weather.daymtx"]                    
                }               
            end
        end

        class GenSkyVec < Task
            def initialize(sky)                
                @target = sky
                @proc = Proc.new{ |options|

                    mf = options["sky_bins"]                    
                    skycolor = [0.960, 1.004, 1.118]
                    dosky = true
                    headout = true

                    OS.run_command "#{sky} > t.tmp"
                    skydesc = File.read("t.tmp")
                    FileUtils.rm("t.tmp")
                    if not skydesc then
                        UI.messagebox "Error: No sky description in genskyvec!"
                        return false
                    end

                    #all these were defined in PERL
                    skydesc = skydesc.split( /\r?\n/ ) #this was created empty, and "pushed" each line.
                    lightline=false
                    sunval = []
                    sunline = false
                    skyOK = false
                    srcmod = false

                    skydesc.each_with_index {|line, index|
                        if line.include? "light" then
                            lightline = index
                            sunval = skydesc[index+3].split(" ")[1..4].map{|x| x.to_f}
                            srcmod = line.split(" ").pop
                        elsif line.include? "source"
                            sunline = index
                        elsif line.include? "skyfunc"
                            skyOK = true
                        end
                    }

                    # Strip out the solar source if present
                    sundir = false
                    if sunline then
                        sundir = skydesc[sunline+3].split(" ").map{|x| x.to_f}
                        sundir.shift
                        sundir = false if sundir[2] <= 0 #if the sun is below the horizon
                        #remove the sun... did not find how to splice (as in Perl)
                        5.times{skydesc.delete_at(sunline)}
                    end

                    # Reinhart sky sample generator
                    rhcal = 'DEGREE : PI/180;'
                    rhcal +='x1 = .5; x2 = .5;'
                    rhcal +='alpha : 90/(MF*7 + .5);'
                    rhcal +='tnaz(r) : select(r, 30, 30, 24, 24, 18, 12, 6);'
                    rhcal +='rnaz(r) : if(r-(7*MF-.5), 1, MF*tnaz(floor((r+.5)/MF) + 1));'
                    rhcal +='raccum(r) : if(r-.5, rnaz(r-1) + raccum(r-1), 0);'
                    rhcal +='RowMax : 7*MF + 1;'
                    rhcal +='Rmax : raccum(RowMax);'
                    rhcal +='Rfindrow(r, rem) : if(rem-rnaz(r)-.5, Rfindrow(r+1, rem-rnaz(r)), r);'
                    rhcal +='Rrow = if(Rbin-(Rmax-.5), RowMax-1, Rfindrow(0, Rbin));'
                    rhcal +='Rcol = Rbin - raccum(Rrow) - 1;'
                    rhcal +='Razi_width = 2*PI / rnaz(Rrow);'
                    rhcal +='RAH : alpha*DEGREE;'
                    rhcal +='Razi = if(Rbin-.5, (Rcol + x2 - .5)*Razi_width, 2*PI*x2);'
                    rhcal +='Ralt = if(Rbin-.5, (Rrow + x1)*RAH, asin(-x1));'
                    rhcal +='Romega = if(.5-Rbin, 2*PI, if(Rmax-.5-Rbin, '
                    rhcal +='	Razi_width*(sin(RAH*(Rrow+1)) - sin(RAH*Rrow)),'
                    rhcal +='	2*PI*(1 - cos(RAH/2)) ) );'
                    rhcal +='cos_ralt = cos(Ralt);'
                    rhcal +='Dx = sin(Razi)*cos_ralt;'
                    rhcal +='Dy = cos(Razi)*cos_ralt;'
                    rhcal +='Dz = sin(Ralt);'

                    nbins=false
                    octree="oct.tmp"
                    file = "sky.tmp"
                    tmp1 = "tmp1.tmp"
                    tmp2 = "tmp2.tmp"
                    tregcommand=false
                    suncmd=false
                    if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil then #if windows
                        OS.run_command "rcalc -n -e MF:#{mf} -e \"#{rhcal}\" -e \"\$1=Rmax+1\" > t.tmp"
                        nbins = File.read "t.tmp"
                        FileUtils.rm "t.tmp"
                        nbins = nbins.to_i
                        tregcommand = "cnt #{nbins} 16 | rcalc -e MF:#{mf} -e \"#{rhcal}\" "
                        tregcommand +="-e \"Rbin=$1;x1=rand(recno*.37-5.3);x2=rand(recno*-1.47+.86)\" "
                        tregcommand +="-e \"$1=0;$2=0;$3=0;$4=Dx;$5=Dy;$6=Dz\" "
                        tregcommand +=" | rtrace -h -ab 0 -w #{octree} | total -16 -m"
                        if sundir then
                            suncmd = "cnt  #{nbins-1}"
                            suncmd +=	" | rcalc -e MF:#{mf} -e \"#{rhcal}\" -e Rbin=recno "
                            suncmd +=	"-e \"dot=Dx*#{sundir[0]} + Dy*#{sundir[1]} + Dz*#{sundir[2]}\" "
                            suncmd +=	"-e \"cond=dot-.866\" "
                            suncmd +=	" -e \"$1=if(1-dot,acos(dot),0);$2=Romega;$3=recno\" "
                        end
                    else
                        OS.run_command "rcalc -n -e MF:#{mf} -e \'#{rhcal}\' -e \'\$1=Rmax+1\' > t.tmp"
                        nbins = File.read "t.tmp"
                        FileUtils.rm "t.tmp"
                        nbins = nbins.to_i
                        tregcommand = "cnt #{nbins} 16 | rcalc -of -e MF:#{mf} -e '#{rhcal}' "
                        tregcommand +="-e 'Rbin=$1;x1=rand(recno*.37-5.3);x2=rand(recno*-1.47+.86)' "
                        tregcommand +="-e '$1=0;$2=0;$3=0;$4=Dx;$5=Dy;$6=Dz' "
                        tregcommand +="| rtrace -h -ff -ab 0 -w #{octree} | total -if3 -16 -m "
                        if sundir then
                            suncmd = "cnt  #{nbins-1} "
                            suncmd +=" | rcalc -e MF:#{mf} -e '#{rhcal}' -e Rbin=recno "
                            suncmd +="-e 'dot=Dx*#{sundir[0]} + Dy*#{sundir[1]} + Dz*#{sundir[2]}' "
                            suncmd +="-e 'cond=dot-.866' "
                            suncmd +=" -e '$1=if(1-dot,acos(dot),0);$2=Romega;$3=recno'"
                        end
                    end
                    tregval = false
                    if dosky then
                        # Create octree for rtrace
                        File.open(file,'w'){|f|
                            f.puts skydesc
                            f.puts "skyfunc glow skyglow 0 0 4 #{skycolor.join(" ")} 0\n"
                            f.puts "skyglow source sky 0 0 4 0 0 1 360\n"
                        }
                        OS.run_command("oconv #{file} > #{octree}")                        
                        OS.run_command "#{tregcommand} > #{tmp1}"
                        tregval = File.readlines(tmp1)
                    else
                        nbins.times{tregval.push "0\t0\t0\n"}
                    end

                    if sundir then
                        somega = (sundir[3]/360)**2 * 3.141592654**3
                        OS.run_command "#{suncmd} > #{tmp2}"
                        bestdir = File.readlines(tmp2).map{|x| x.split(" ").map{|y| y.to_f}}
                        FileUtils.rm(tmp2)
                        bestdir = bestdir.sort {|a,b| a[0] <=> b[0]}

                        ang=[]
                        dom=[]
                        ndx=[]
                        wtot = 0
                        3.times{|i|
                            ang[i]=bestdir[i][0]
                            dom[i]=bestdir[i][1]
                            ndx[i]=bestdir[i][2]
                            wtot += 1.0/(ang[i]+0.02)
                        }
                        3.times{|i|
                            wt = 1.0/(ang[i]+0.02)/wtot * somega / dom[i]
                            scolor = tregval[ndx[i]].split(" ").map{|x| x.to_f}
                            3.times{|j| scolor[j] += wt * sunval[j] }
                            tregval[ndx[i]] = "#{scolor[0]}\t#{scolor[1]}\t#{scolor[2]}\n";
                        }
                    end

                        ret = []
                        # Output header if requested
                        if headout then
                            ret.push "#?RADIANCE"
                            ret.push "genskyvec ... to do."
                            ret.push "NROWS=#{tregval.length}"
                            ret.push "NCOLS=1"
                            ret.push "NCOMP=3"
                            ret.push "FORMAT=ascii"
                            ret.push ""
                        end
                        # Output our final vector
                        ret = ret + tregval
                        FileUtils.rm(file)
                        FileUtils.rm(octree)
                        FileUtils.rm(tmp1)

                        File.open("./Skies/#{Utilities.fix_name(sky)}.skv",'w'){|f|
                            ret.each{|line|
                                f.puts line
                            }                             
                        }
                        next []
                }
            end 
        end #end genskyvec


    end
end