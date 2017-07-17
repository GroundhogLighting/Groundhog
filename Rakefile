require 'fileutils'
require 'JSON'

task :default => :all

task :all => [:win32, :win64, :macosx] do
	FileUtils.rm_rf "./IGD_Groundhog/src/Radiance"
end

task :doc => [:clean] do
	puts `yardoc ./IGD_Groundhog/src/*.rb ./IGD_Groundhog/src/Scripts/*.rb - ./Readme.md`
	FileUtils.rm_rf("IGD_Groundhog/doc")
	FileUtils.cp_r("doc","IGD_Groundhog/doc")
end

task :clean do
	FileUtils.rm(Dir["IGD_Groundhog/Examples/*.skb"])
	FileUtils.rm(Dir["*.rbz"])
	FileUtils.rm_rf("doc")
end

def sketchup_plugin_dir(os,v)
	if os == "macosx" then
		return "#{ENV["HOME"]}/Library/Application Support/SketchUp #{v}/SketchUp/Plugins"
	else
	 return "#{ENV["UserProfile"].gsub("\\","/")}/AppData/Roaming/SketchUp/SketchUp #{v}/SketchUp/Plugins"
	end
end



task :test,[:os, :suv] => [:compile_ui] do |t, args|
	radiance_version = "Radiance/#{args[:os]}/Radiance"
	radiance_version = "Radiance/macosx/usr/local/radiance" if args[:os] == "macosx"

	# Replace the Radiance version in Groundhog
	FileUtils.rm_rf("./IGD_Groundhog/src/Radiance")
	FileUtils.cp_r radiance_version, "./IGD_Groundhog/src/Radiance"

	# Remove the groundhog version in Sketchup Plugin directory
	FileUtils.rm_rf "#{sketchup_plugin_dir(args[:os],args[:suv])}/IGD_Groundhog.rb"
	FileUtils.rm_rf "#{sketchup_plugin_dir(args[:os],args[:suv])}/IGD_Groundhog"

	# Move the new one
	FileUtils.cp_r "IGD_Groundhog.rb","#{sketchup_plugin_dir(args[:os],args[:suv])}/IGD_Groundhog.rb"
	FileUtils.cp_r "IGD_Groundhog","#{sketchup_plugin_dir(args[:os],args[:suv])}/IGD_Groundhog"

	# Final clean
	FileUtils.rm_rf("./IGD_Groundhog/src/Radiance")
end

def this_os
	if RUBY_PLATFORM.include? "darwin" then
		return "macosx"
	else
		return "win"
	end
end

def compress(os)
	radiance_version = "Radiance/#{os}/Radiance"
	radiance_version = "Radiance/macosx/usr/local/radiance" if os == "macosx"	
	FileUtils.rm_rf("./IGD_Groundhog/src/Radiance")
	FileUtils.cp_r radiance_version, "./IGD_Groundhog/src/Radiance"	
	
	File.open("listfile.txt",'w'){|w|
		w.puts "IGD_Groundhog.rb"
		w.puts "IGD_Groundhog"
	}
	puts `7z a -tzip Groundhog_#{os}.rbz @listfile.txt -x!.yardoc -x!*.DS_Store`
	FileUtils.rm "listfile.txt"
	
end

task :win64 => [:clean, :add_build_date, :compile_ui] do
	compress("win64")
end
task :win32 => [:clean, :add_build_date, :compile_ui] do
	compress("win32")
end
task :macosx => [:clean, :add_build_date, :compile_ui] do
	compress("macosx")
end

task :add_build_date do
	File.open("IGD_Groundhog/built",'w'){|file|
		file.puts Time.now
	}
end


@ui_src = "./ui-src"
def change_ui_version(version)
	File.open("#{@ui_src}/ts/version.ts",'w'){ |f| 
		f.puts "export = '#{version}';"
	}
end	

def compile_ui(version)
	change_ui_version(version)
	warn `tsc --p #{@ui_src}`
	warn `browserify #{@ui_src}/js/main.js --standalone DesignAssistant -o ./IGD_Groundhog/src/html/js/design_assistant_#{version}.js`

	File.open("./IGD_Groundhog/src/html/design_assistant_#{version}.html",'w'){|file|
		file.puts "<!DOCTYPE html>
						<html>

						<head>
							<title>Design assistant</title>
							<meta charset='UTF-8'>
							<meta http-equiv='X-UA-Compatible' content='IE=edge'/>

							<link href='css/jquery-ui.css' rel='stylesheet'>
							<link href='css/groundhog-ui.css' rel='stylesheet'>
							<link rel='stylesheet' href='css/spectrum.css' />
						</head>

						<body>"
		
		selected = "location"
		sections = ["location","materials","luminaires","photosensors","objectives","calculate","report"] #"observers",
		
		# Create the tabs
		file.puts "<div id='sidenav'>"
		sections.each{|section|
			file.puts "<p #{selected == section ? "class = 'selected'" : ''} href='##{section}'>#{section.capitalize}</p>"
		}
		file.puts "</div>"

		# add the actual sections
		sections.each{|section|
			file.puts File.readlines("#{@ui_src}/ts/#{section}/template.html")
		}

		file.puts "
					<script src='js/JQuery/jquery-3.0.0.js'></script>
					<script src='js/jQueryUI/jquery-ui.js'></script>
					<script src='js/Spectrum/spectrum.js'></script>    
					<script src='js/groundhog-ui.js'></script>
					
					<script src='js/design_assistant_#{version}.js'></script>    
					
					<script>
						var DesignAssistant = new DesignAssistant();        
						DesignAssistant.update();
					</script>
					
				</body>

				</html>
				"
	}
end

task :test_ui do
	compile_ui("debug")
end

task :compile_ui do	
	["web_dialog"].each{|version|
		compile_ui(version)
	}
end
