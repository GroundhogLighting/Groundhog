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


def change_ui_version(version)
	File.open("#{@ui_src}/common/version.ts",'w'){ |f| 
		f.puts "export = '#{version}';"
	}
end	

def compile_design_assistant(version)
	
	destination = "./GH_Groundhog/src/html"
	origin = "./ui-src"
	Dir.chdir(origin){
		# Generate a dist folder with the compiled
		warn `npm run generate` 		
	}
	# Replace javascript fileutils
	FileUtils.rm_rf("#{destination}/#{version}")
	FileUtils.cp_r("#{origin}/dist","#{destination}/#{version}")
end

task :test_ui do
	["debug"].each{|version|
		["designassistant"].each{|app|	
			compile_ui(app,version)
		}
	}
end

task :compile_design_assistant do	
=begin
	["debug"].each{|version|
		["designassistant"].each{|app|	
			compile_ui(app,version)
		}
	}
=end	
	compile_design_assistant("html_dialog")
end
