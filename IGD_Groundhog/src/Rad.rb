module IGD
	module Groundhog
		module Rad
			#This module calls Radiance for performing calculations

			# Calculates the daylight factor for the workplanes in the scene
			# @author German Molina
			# @param void			
			def self.daylight_factor
				path=OS.tmp_groundhog_path
				Exporter.export(path)
				FileUtils.cd(path) do
					if not File.directory?("Workplanes") 
						UI.messagebox("There are no workplanes to calculate")
						return false
					end

					OS.mkdir("Results")
			
					#build the script	
					script=[]
					#add overcast sky
					script << "gensky -ang 45 0 -c -B 0.5586592 > Skies/sky.rad"
					script << "echo 'skyfunc glow skyglow 0 0 4 1 1 1 0     skyglow source skyball 0 0 4 0 0 1 360'  >> Skies/sky.rad"
					#oconv
					if File.directory?("Windows") then
						script << "oconv ./Materials/materials.mat ./scene.rad ./Windows/* > octree.oct"
					else
						script << "oconv ./Materials/materials.mat ./scene.rad > octree.oct"
					end
				
					wps=Dir["Workplanes/*"]
					results=[]				
					wps.each do |workplane|
						info=workplane.split("/")
						name=info[1].split(".")[0]
						results << name
						script << "rtrace -h -I+ -oov #{Config.rtrace_options} -n #{Config.n_threads} octree.oct < #{workplane} | rcalc -e '$1=$1; $2=$2; $3=$3; $4=179*(0.265*$4+0.67*$5+0.065*$6)' > Results/#{name}.txt"
					end
				
					success=OS.execute_script(script)
					return if not success
				
					results.each do |res|
						Results.import_results("Results/#{res}.txt")
					end
				
					OS.clear_actual_path				
				end
			end

			# Calls RVU for previewing the actual scene from the current view.
			# @author German Molina
			# @param void			
			def self.rvu
				path=OS.tmp_groundhog_path
				Exporter.export(path)
				
				FileUtils.cd(path) do	
					script=[]
								
					#oconv
					if File.directory?("Windows") then
						script << "oconv ./Materials/materials.mat ./scene.rad ./Windows/* > octree.oct"
					else
						script << "oconv ./Materials/materials.mat ./scene.rad > octree.oct"
					end
				
					script << "rvu #{Config.rvu_options} -n #{Config.n_threads} -vf Views/view.vf octree.oct"

					success = OS.execute_script(script)
					OS.clear_actual_path
				end	
			end
		
		
	
		end #end class
	end #end module
end