module IGD
	module Groundhog
		module Rad
			#This module calls Radiance for performing calculations

			# Gets the String that reference all the Windows
			# @author German Molina
			# @return [String] All the files
			def self.gather_windows
				winstring=Dir["Windows/*"]
				if winstring.length > 0 then
					return  "./"+winstring.join(" ./").gsub("\\","/")
				end
				return ""
			end

			# Gets the String that reference all the  TDDs
			# @author German Molina
			# @return [String] All the files
			def self.gather_tdds
				tdd_string=Dir["TDDs/*"]
				if tdd_string.length > 0 then
					return  "./"+tdd_string.join(" ./").gsub("\\","/")
				end
				return ""
			end

			# Gets the String that reference all the top lenses of the TDDs
			# @author German Molina
			# @return [String] All the files
			def self.gather_tdd_tops
				tdd_string=Dir["TDDs/*.top"]
				if tdd_string.length > 0 then
					return  "./"+tdd_string.join(" ./").gsub("\\","/")
				end
				return ""
			end

			# Gets the String that reference all the bottom lenses of the TDDs
			# @author German Molina
			# @return [String] All the files
			def self.gather_tdd_bottoms
				tdd_string=Dir["TDDs/*.bottom"]
				if tdd_string.length > 0 then
					return  "./"+tdd_string.join(" ./").gsub("\\","/")
				end
				return ""
			end

			# Gets the String that reference all the pipes of the TDDs
			# @author German Molina
			# @return [String] All the files
			def self.gather_tdd_pipes
				tdd_string=Dir["TDDs/*.pipe"]
				if tdd_string.length > 0 then
					return  "./"+tdd_string.join(" ./").gsub("\\","/")
				end
				return ""
			end

			# Calculates and plots the UDI
			# @author German Molina
			# @param da [Boolean] Parameter that sais if we are calculating DA or UDI.
			# @return [Boolean] Success
			def self.calc_UDI(da)
				path=Sketchup.temp_dir
				FileUtils.cd(path) do
					return false if not OS.execute_script(self.calc_annual_illuminance)
					wps=Dir["Workplanes/*.pts"]
					max = Config.max_illuminance
					max = 9e16 if da #basically, ignore this threshold
					wps.each do |workplane| #calculate UDI for each workplane
						info=workplane.split("/")
						name=info[1].split(".")[0]
						values=Results.annual_to_UDI("#{Sketchup.temp_dir}/Results/#{name}_DC.txt", "#{Sketchup.temp_dir}/Workplanes/#{name}.pts", Config.min_illuminance, max, Config.early, Config.late)
						return if not values #if the format was wrong, for example

						pixels = Utilities.readTextFile("#{Sketchup.temp_dir}/Workplanes/#{name}.pxl",",",0)
						metric = "U.D.I."
						metric = "Daylight authonomy" if da
						Results.draw_pixels(values,pixels,name.tr("_"," "),metric)
						min_max=Results.get_min_max_from_model(metric)
						Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
					end
				end
				return true
			end

			# Calculates and plots the Daylight Autonomy
			# @author German Molina
			# @return [Boolean] Success
			def self.calc_DA
				self.calc_UDI(true)
			end


			# Calculates the annual illuminance using a chosen method
			# @author German Molina
			# @return [Boolean] Success
			def self.calc_annual_illuminance
				path=Sketchup.temp_dir
				script=[]

				FileUtils.cd(path) do
					file="./Skies/weather.wea"
					if not File.exist? file then
						UI.messagebox "Please set up a Weather File.\n This is done in the Groundhog/Preferences/Project tab."
						return false
					end

					#Calculate DC matrices
					case Config.dynamic_calculation_method
					when "DC"
						dc=self.calc_DC(Config.dynamic_sky_bins)
						return false if not dc
						script += dc
					else
						UI.messagebox "Calculation method not recognized when trying to assess the Annual Illuminance"
						return false
					end

					#Simulate
					wps=Dir["Workplanes/*.pts"]

					OS.mkdir("Results")
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						#OSX
						script << "gendaymtx -m #{Config.dynamic_sky_bins} -g #{Config.albedo} #{Config.albedo} #{Config.albedo} Skies/weather.wea > tmp1.tmp"
						script << "dctimestep DC/#{name}.dc tmp1.tmp > tmp2.tmp"
						script << "rmtxop -fa tmp2.tmp > tmp3.tmp"
						script << "rcollate -ho -oc 1 tmp3.tmp > tmp4.tmp "

						#OSX
						script << "rcalc -e '$1=179*(0.265*$1+0.67*$2+0.065*$3)' tmp4.tmp > Results/#{name}_DC.txt" if OS.getsystem=="MAC"
						#WIN
						script << "rcalc -e \"$1=179*(0.265*$1+0.67*$2+0.065*$3)\" tmp4.tmp > Results/#{name}_DC.txt" if OS.getsystem=="WIN"
					end
				end
				return script
			end


			# Exports the files and creates the script for calculating the simplest DC
			# this will include the TDDs (if any) and the sky.
			# @author German Molina
			# @param bins [Integer] The number of MF Reinhart subdivitions
			# @return [Array<String>] The Script if success, false if not.
			def self.calc_DC(bins)
				path=Sketchup.temp_dir

				FileUtils.cd(path) do
					if not File.directory?("Workplanes") then
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					OS.mkdir("DC")

					#modify sky
					File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
						f.write(Exporter.white_sky(Config.dynamic_sky_bins))
					}

					#build the script
					script=[]
					
					#second, add the TDD contribution if exists.
					script += self.calc_TDD_contributions if File.directory? "TDDs"

					#Third, calculate the total contribution
					unique_tdds=Dir["TDDs/*.pipe"].map{|x| x.split("/").pop.split(".").shift.split("-").pop}.uniq
					wps=Dir["Workplanes/*.pts"]
					wps.each {|workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						wp_name = Utilities.fix_name(name)
						all_tdds = ["DC/#{wp_name}-sky.dc"]
						unique_tdds.each{|tdd_name|
							index = 0
							while File.file? "TDDs/#{index}-#{tdd_name}.pipe" do
								all_tdds << "DC/#{wp_name}-#{index}-#{tdd_name}.dc"
								index+=1
							end
						}

						script << "rmtxop #{all_tdds.join(" + ")} > DC/#{wp_name}.dc"
					}
					return script
				end
			end

			# Calculates the DC from the workplanes to the Sky, ignoring TDDs and Luminaires
			# @author German Molina
			# @return [Array<String>] The Script if success, false if not.
			def self.calc_SKY_contribition
				script = []
				wps=Dir["Workplanes/*.pts"]
				wps.each { |workplane|
					info=workplane.split("/")
					name=info[1].split(".")[0]
					nsensors = File.readlines(workplane).length
					script << "rfluxmtx -I+ -y #{nsensors} #{Config.rcontrib_options} < #{workplane} - Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/#{name}-sky.dc"
				}
				return script
			end

			# Calculates the DC from the workplanes to the sky THROUGH THE TDDs, ignoring
			#  light entering thorugh windows and contribution from luminaires
			# @author German Molina
			# @return [Array<String>] The Script if success, false if not.
			def self.calc_TDD_contributions
				script = []
				unique_tdds=Dir["TDDs/*.pipe"].map{|x| x.split("/").pop.split(".").shift.split("-").pop}.uniq
				wps=Dir["Workplanes/*.pts"]
				### First, the Daylight matrix
				tdds=Dir["TDDs/*.top"] #get all the TDD tops.
				if Config.tdd_singledaymtx then
					sender = tdds.shift
					info=sender.split("/")
					name=info[1].split(".")[0]
					script << "rfluxmtx #{Config.tdd_daylight_rfluxmtx} #{sender} Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/ALL_TDDs-sky.mtx"
				else
					tdds.each do |sender|
						info=sender.split("/")
						name=info[1].split(".")[0]
						script << "rfluxmtx #{Config.tdd_daylight_rfluxmtx} #{sender} Skies/sky.rad Materials/materials.mat scene.rad #{self.gather_windows} > DC/#{name}-sky.mtx"
					end
				end

				### Second, calculate the View matrices
				wps.each do |workplane|
					bottoms = ""
					info=workplane.split("/")
					name=info[1].split(".")[0]
					wp_name = Utilities.fix_name(name)
					nsensors = File.readlines(workplane).length

					Dir["TDDs/*.bottom"].each{|bottom| #get all the TDD bottoms.
						info=bottom.split("/")
						tdd_name=info[1].split(".")[0]
						bottoms += "\#@rfluxmtx h=kf u=Y o=DC/#{wp_name}-#{tdd_name}.vmx\n\n"
						bottoms += File.open(bottom, "rb").read
					}

					File.open("DC/#{wp_name}_receiver.rad",'w'){|x| x.puts bottoms}

					script << "rfluxmtx -y #{nsensors} -I+ #{Config.tdd_view_rfluxmtx} < #{workplane} - DC/#{wp_name}_receiver.rad Materials/materials.mat scene.rad #{self.gather_windows}"
				end

				### Third, calculate the flux matrix from one lens to the other.
				unique_tdds.each{|x|
					sender = "TDDs/#{x}_bottom.rad"
					receiver = "TDDs/0-#{x}.top"
					pipe = "TDDs/0-#{x}.pipe"
					File.open(sender,'w'){|b|
						b.puts "\#@rfluxmtx h=kf u=Y\n"
						b.puts File.open("TDDs/0-#{x}.bottom", "rb").read
					}
					script << "rfluxmtx #{Config.tdd_pipe_rfluxmtx} #{sender} #{receiver} #{pipe} > DC/#{x}-pipe.mtx"
				}

				### Fourth: Multiply all the parts of all TDDs
				wps.each do |workplane|
					info=workplane.split("/")
					name=info[1].split(".")[0]
					wp_name = Utilities.fix_name(name)
					unique_tdds.each{|tdd_name|
						index = 0
						while File.file? "TDDs/#{index}-#{tdd_name}.pipe" do
							top_lens_bsdf = "./TDDs/#{tdd_name}_top.xml" #has to match the one given in TDD.write_tdd
							bottom_lens_bsdf= "./TDDs/#{tdd_name}_bottom.xml"
							daymtx = "DC/#{index}-#{wp_name}-sky.mtx"
							daymtx = "DC/ALL_TDDs-sky.mtx" if Config.tdd_singledaymtx
							script << "rmtxop DC/#{wp_name}-#{index}-#{tdd_name}.vmx #{bottom_lens_bsdf.strip} DC/#{tdd_name}-pipe.mtx #{top_lens_bsdf.strip} #{daymtx} > DC/#{wp_name}-#{index}-#{tdd_name}.dc"
							index+=1
						end
					}

				end
				return script
			end


			# Writes the files and return the script for calculating the Actual illuminance
			# @author German Molina
			# @param sky [String] A String with the sky command
			# @return [Array<String>] Script if succesfull, false if not.
			def self.instant_illuminance(sky, lights_on, daytime)

				path=Sketchup.temp_dir
				script=[]

				FileUtils.cd(path) do
					if not File.directory?("Workplanes")
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					case Config.static_calculation_method
					when "RTRACE"
						File.open("Skies/sky.rad",'w+'){ |f| #The file is opened
							f.write("!#{sky}\n\n")
							f.write(Exporter.sky_complement)
						}
						script << "oconv ./Materials/materials.mat ./scene.rad ./Skies/sky.rad #{self.gather_windows} > octree.oct"
						wps=Dir["Workplanes/*.pts"]
						wps.each do |workplane|
							info=workplane.split("/")
							name=info[1].split(".")[0]
							script << "rtrace -h -I+ -af ambient.amb -oov #{Config.rtrace_options} octree.oct < #{workplane} > tmp1.tmp"

							#for OSX
							script << "rcalc -e '$1=179*(0.265*$4+0.67*$5+0.065*$6)' tmp1.tmp > Results/#{name}.txt" if OS.getsystem=="MAC"
							#for Windows
							script << "rcalc -e \"$1=179*(0.265*$4+0.67*$5+0.065*$6)\" tmp1.tmp > Results/#{name}.txt" if OS.getsystem=="WIN"
						end
					when "DC"
						#UI.messagebox "This feature is still under development. We are sorry!"
						#return true
						skyvecfile = "skyvec.rad"
						#generate the sky vector
						File.open(skyvecfile,'w'){|s|
							vec = self.genskyvec(Config.static_sky_bins, [0.960, 1.004, 1.118],true,true, sky)
							warn vec.length
							vec.each do |line|
								s.puts line
							end
						}
						# Calc DC
						dc = self.calc_DC(Config.static_sky_bins)
						return false if not dc
						script += dc
						wps=Dir["Workplanes/*.pts"]
						wps.each do |workplane|
							info=workplane.split("/")
							name=info[1].split(".")[0]
							script << "rmtxop DC/#{name}.dc #{skyvecfile} > tmp1.tmp "
							script << "rmtxop -fa -c 47.4 119.9 11.6 tmp1.tmp > tmp2.tmp "
							script << "rcollate -oc 1 -ho > Results/#{name}.txt"
						end
					else
						UI.messagebox "Unkown method for calculating Instant Illuminance"
						return false
					end

				end
				return script
			end

			# Creates the script for calling RVU and previewing the model
			# @author German Molina
			# @param scene [String] The scene to review
			# @return [Array<String>] Script
			def self.rvu(scene)
				path=Sketchup.temp_dir
				script=[] #
				FileUtils.cd(path) do
					#oconv
					script << "oconv ./Materials/materials.mat ./scene.rad  ./Skies/sky.rad  #{self.gather_windows} #{self.gather_tdds} > octree.oct"
					script << "rvu #{Config.rvu_options} -vf Views/#{scene}.vf octree.oct"
				end
				return script
			end



			# Returns the javascript for loading the Scenes (Pages) into the GUI
			# for previsualization
			# @author German Molina
			# @return [String] Script
			def self.load_views
				script = "var select = document.getElementById('rvu_scene');"
				script += "var option =  document.createElement('option');"
				script += "option.value = 'view';"
				script += "option.text = 'actual view';"
				script += "select.add(option);"

				Sketchup.active_model.pages.each do |page|
					name = page.name
					value = Utilities.fix_name(name)
					script += "var option =  document.createElement('option');"
					script += "option.value = '#{value}';"
					script += "option.text = '#{name}';"
					script += "select.add(option);"
				end
				return script
			end

			@@default_metrics = {
				"Review" => {:action => "rvu()", :html => "<h2>Review model</h2><fieldset><legend>Scene to review</legend><select id='rvu_scene'></select></fieldset><p align='center'><button onclick='load_rvu_views()'>Refresh views</button> <button onclick='rvu()'>Review </button></p>"},
				"Instant illuminance" => {:action => "calc_instant_illuminance()", :html => "<h2>Instant illuminance</h2><fieldset><legend>Sky model</legend><select id='instant_illuminance_sky'><option value='-u'>CIE Uniform</option><option value='-c'>CIE Overcast</option><option value='+i'>CIE Intermediate</option><option value='+s'>CIE Clear</option></select><div class='option_info'>?<div class='tooltip'><p>The sun's position is obtained from the SketchUp model.</p></div></div></fieldset><p align='center'> <button onclick='calc_instant_illuminance()'> Calculate </button></p><table align='center'><tr><td id='instant_illuminance_scale_min'></td><td><img align='center' src='images/scale_horizontal.png' alt='scale' style='width:200px;height:30px'></td><td id='instant_illuminance_scale_max'></td></tr></table><table id='instant_illuminance_results' class='with_border'></table>"},
				"Daylight factor" => {:action => "calc_DF()"},
				"Daylight authonomy" => {:action => "calc_DA()"},
				"U.D.I." => {:action => "calc_UDI()"}
			}

			# Returns the javascript for adding a metric to the GUI
			# @author German Molina
			# @param metric [String] the metric to add
			# @return [String] Script
			def self.add_metric(metric)
				fixed_name = Utilities.fix_name(metric).downcase
				directives = @@default_metrics[metric]

				#the tab first
				script  = "var tabs = document.getElementById('tabs');"
				script += "var li = document.createElement('li');"
				script += "li.innerHTML=\"<a href='\##{fixed_name}'>#{metric}</a>\";"
				script += "li.setAttribute('class','selected');" if metric == @@default_metrics.keys[0]
				script += "li.onclick = function(){select_metric('#{metric}')};"
				script += "tabs.appendChild(li);"

				#then the content
				script += "var div = document.createElement('div');"
				script += "div.setAttribute('id','#{fixed_name}');"
				script += "div.setAttribute('class','tabContent hide');"
				script += "div.setAttribute('class','tabContent');" if metric == @@default_metrics.keys[0]

				button = ""
				button = "<p align='center'><button onclick='#{directives[:action]}'> Calculate </button></p>" if directives != nil and directives[:action] != nil

				inner_html="<h2>#{metric}</h2>#{button}<table align='center'><tr><td id='#{fixed_name}_scale_min'></td><td><img align='center' src='images/scale_horizontal.png' alt='scale' style='width:200px;height:30px'></td><td id='#{fixed_name}_scale_max'></td></tr></table><table id='#{fixed_name}_results' class='with_border'></table>"
				inner_html = directives[:html] if directives != nil and directives[:html] != nil

				script += "div.innerHTML = \"#{inner_html}\";"
				script += "document.body.appendChild(div);"
				return script
			end

			# Returns a script that needs to be run to update the metric results table
			# @author German Molina
			# @return [String] The javascript script that needs to be run to update the metric results table
			def self.refresh_table(metric)
				return "" if metric == "Review"
				fixed_name=Utilities.fix_name(metric).downcase

				#select workplanes with the corresponding metric
				workplanes = Results.get_workplane_list.select{|x| JSON.parse(Labeler.get_value(x))["metric"] == metric}
				return "" if workplanes.length == 0 #return if there are none.
				scale=Results.get_scale_from_model(metric)
				#get the script
				script=""
				script += "var table = document.getElementById('#{fixed_name}_results');"
				script += "table.innerHTML = '<tr><td></td><td>Average</td><td>Minimum</td><td>Maximum</td><td>Min / Average</td><td>Min / Max</td></tr>';"
				workplanes.each do |workplane|
					data = JSON.parse(Labeler.get_value(workplane))

					script += "var row = table.insertRow(-1);"
					#name
					script += "var cell = row.insertCell(0);"
					script += "cell.innerHTML='#{data["workplane"]}';"
					#Average
					script += "cell = row.insertCell(1);"
					script += "cell.innerHTML='#{data["average"].round(1)}';"
					#Minimum
					script += "cell = row.insertCell(2);"
					script += "cell.innerHTML='#{data["min"].round(1)}';"
					#Maximum
					script += "cell = row.insertCell(3);"
					script += "cell.innerHTML='#{data["max"].round(1)}';"
					#Min/Average
					script += "cell = row.insertCell(4);"
					script += "cell.innerHTML='#{data["min_over_average"].round(3)}';"
					#Min/Max
					script += "cell = row.insertCell(5);"
					script += "cell.innerHTML='#{data["min_over_max"].round(3)}';"
				end
				#update scale
				script += "document.getElementById('#{fixed_name}_scale_min').innerHTML='#{scale[0].round(0)}';"
				script += "document.getElementById('#{fixed_name}_scale_max').innerHTML='#{scale[1].round(0)}';"
				return script
			end

			# Returns the javascript for adding all the metrics to the GUI
			# @author German Molina
			# @return [String] Script
			def self.load_metrics
				script = ""
				metrics = @@default_metrics.keys + Results.get_metrics_list
				metrics.uniq!
				metrics.each {|key|
					script+= self.add_metric(key)
					script+= self.refresh_table(key)
				}

				script+="init();"
				script += self.load_views
				return script
			end

			def self.show_sim_wizard
				wd=UI::WebDialog.new(
				"Simulation wizard", false, "",
				595, 490, 100, 100, true )

				wd.set_file("#{OS.main_groundhog_path}/src/html/simulation.html" )

				wd.add_action_callback("load_views") do |web_dialog,msg|
					web_dialog.execute_script(self.load_views)
				end


				wd.add_action_callback("onLoad") do |web_dialog,msg|
					web_dialog.execute_script(self.load_metrics)
				end

				wd.add_action_callback("select_metric") do |web_dialog,msg|
					Utilities.remark_solved_workplanes(msg)
				end

				wd.add_action_callback("rvu") do |web_dialog,msg|
					next if not Exporter.export(Sketchup.temp_dir)
					FileUtils.cd(Sketchup.temp_dir) do
						begin
							view = JSON.parse(msg)
							OS.execute_script(self.rvu(view["scene"]))
							OS.clear_actual_path
						rescue Exception => ex
							UI.messagebox ex
						end
					end

				end

				wd.add_action_callback("calc_DF") do |web_dialog,msg|
					next if not Exporter.export(Sketchup.temp_dir)
					FileUtils.cd(Sketchup.temp_dir) do
						begin
							sky = "gensky -ang 45 40 -c -B 0.5586592 -g #{Config.albedo}"

							OS.mkdir("Results")
							OS.execute_script(self.instant_illuminance(sky, false, true)) #lights off and daytime
							wps=Dir["Workplanes/*.pts"]
							results=[]
							wps.each do |workplane|
								info=workplane.split("/")
								name=info[1].split(".")[0]
								results << name
							end

							metric = "Daylight factor"
							results.each do |res|
								Results.import_results("#{Sketchup.temp_dir}/Results/#{res}.txt",metric)
							end
							Utilities.remark_solved_workplanes(metric)
							min_max=Results.get_min_max_from_model(metric)
							Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
							web_dialog.execute_script(self.refresh_table(metric))
						rescue Exception => ex
							UI.messagebox ex
						end
					end
				end


				wd.add_action_callback("calc_instant_illuminance") do |web_dialog,msg|

					next if not Exporter.export(Sketchup.temp_dir)
					options=JSON.parse(msg)
					FileUtils.cd(Sketchup.temp_dir) do
						begin
							sky = Utilities.get_current_sky(options["sky"])

							OS.mkdir("Results")
							OS.execute_script(self.instant_illuminance(sky, options["lights_on"], options["daytime"]))
							wps=Dir["Workplanes/*.pts"]
							results=[]
							wps.each do |workplane|
								info=workplane.split("/")
								name=info[1].split(".")[0]
								results << name
							end

							metric = "Instant illuminance"
							results.each do |res|
								Results.import_results("#{Sketchup.temp_dir}/Results/#{res}.txt",metric)
							end
							Utilities.remark_solved_workplanes(metric)
							min_max=Results.get_min_max_from_model(metric)
							Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
							web_dialog.execute_script(self.refresh_table(metric))
						rescue Exception => ex
							UI.messagebox ex
						end
					end
				end

				wd.add_action_callback("calc_DA") do |web_dialog,msg|
					next if not Exporter.export(Sketchup.temp_dir)
					self.calc_DA
					metric = "Daylight authonomy"
					Utilities.remark_solved_workplanes(metric)
					min_max=Results.get_min_max_from_model(metric)
					Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
					web_dialog.execute_script(self.refresh_table(metric))
				end

				wd.add_action_callback("calc_UDI") do |web_dialog,msg|
					next if not Exporter.export(Sketchup.temp_dir)
					self.calc_UDI(false)
					metric="U.D.I."
					Utilities.remark_solved_workplanes(metric)
					min_max=Results.get_min_max_from_model(metric)
					Results.update_pixel_colors(0,min_max[1],metric)	#minimum is 0 by default
					web_dialog.execute_script(self.refresh_table(metric))
				end

				wd.show()
			end


			def self.genskyvec(mf, skycolor, dosky, headout, sky)
				OS.run_command "#{sky} > t.tmp"
				skydesc = File.read("t.tmp")
				FileUtils.rm("t.tmp")
				if not skydesc then
					warn "Error: No sky description!"
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
					OS.run_command "oconv #{file} > #{octree}"

					# Run rtrace and average output for every 16 samples
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

					return ret
			end #end genskyvec

		end #end class
	end #end module
end
