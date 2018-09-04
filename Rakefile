require 'fileutils'
require 'JSON'

@ui_src = "./ui-src"

task :default => :all


task :all => [:win64, :macos] do
	FileUtils.rm_rf "./GH_Groundhog/src/Radiance"
end

task :doc => [:clean] do
	puts `yardoc ./GH_Groundhog/src/*.rb ./GH_Groundhog/src/Scripts/*.rb - ./Readme.md`
	FileUtils.rm_rf("GH_Groundhog/doc")
	FileUtils.cp_r("doc","GH_Groundhog/doc")
end

task :clean do
	FileUtils.rm(Dir["GH_Groundhog/Examples/*.skb"])
	FileUtils.rm(Dir["*.rbz"])
	FileUtils.rm_rf("doc")
end

def sketchup_plugin_dir(os,v)
	if os == "macos" then
		return "#{ENV["HOME"]}/Library/Application Support/SketchUp #{v}/SketchUp/Plugins"
	else
	 return "#{ENV["UserProfile"].gsub("\\","/")}/AppData/Roaming/SketchUp/SketchUp #{v}/SketchUp/Plugins"
	end
end

def set_debug(debug)
	fname = "GH_Groundhog/src/Debug.rb"
	
	raise fname+" does not exist" if not File.exist? fname

	File.open(fname, 'w') {|file| 
		file.puts("module GH")
		file.puts("    module Groundhog")
		file.puts("        GH_DEBUG=#{debug}") 
		file.puts("    end") 
		file.puts("end") 		
	}	

end

task :test,[:suv]  do |t, args|
	os = this_os
	if args[:suv]== nil then		
		version = '2017'
	else
		version = args[:suv]
	end		

	warn "Testing version #{version} in #{os}"
	
	# Set debug
	set_debug(true)

	bin_version = "emp/#{os}"	
	
	# Replace the executables version in Groundhog
	FileUtils.rm_rf("./GH_Groundhog/emp")
	FileUtils.cp_r(bin_version, "./GH_Groundhog/emp")

	# Remove the groundhog version in Sketchup Plugin directory
	FileUtils.rm_rf "#{sketchup_plugin_dir(os,version)}/GH_Groundhog.rb"
	FileUtils.rm_rf "#{sketchup_plugin_dir(os,version)}/GH_Groundhog"

	# Move the new one
	FileUtils.cp_r "GH_Groundhog.rb","#{sketchup_plugin_dir(os,version)}/GH_Groundhog.rb"
	FileUtils.cp_r "GH_Groundhog","#{sketchup_plugin_dir(os,version)}/GH_Groundhog"

	# Final clean
	FileUtils.rm_rf("./GH_Groundhog/emp")

	# UnSet debug
	set_debug(false)
end

def this_os
	if RUBY_PLATFORM.include? "darwin" then
		return "macos"
	else
		return "win64" # we only allow WIN64 now.
	end
end

def compress(os)
	bin_version = "emp/#{os}"	

	# Replace the executables version in Groundhog
	FileUtils.rm_rf("./GH_Groundhog/emp")
	FileUtils.cp_r bin_version, "./GH_Groundhog/emp"
	
	File.open("listfile.txt",'w'){|w|
		w.puts "GH_Groundhog.rb"
		w.puts "GH_Groundhog"
	}
	puts `7z a -tzip Groundhog_#{os}.rbz @listfile.txt -x!.yardoc -x!*.DS_Store`
	FileUtils.rm "listfile.txt"
	
end

task :win64 => [:clean, :add_build_date, :design_assistant] do
	compress("win64")
end


task :macos => [:clean, :add_build_date, :design_assistant] do
	compress("macos")
end

task :add_build_date do
	File.open("GH_Groundhog/built",'w'){|file|
		file.puts Time.now
	}
end


def change_ui_version(version)
	File.open("#{@ui_src}/plugins/skp-version.js",'w'){ |f| 
		f.puts "module.exports = '#{version}';"
	}
end	

def set_is_dev(is_dev)
	File.open("#{@ui_src}/plugins/is-dev.js",'w'){ |f| 
		f.puts "module.exports = #{is_dev};"
	}
end	


task :design_assistant,[:version] do |t, args|
	
	destination = "./GH_Groundhog/src/html"	

	if args[:version] == nil then
		versions = ["html_dialog","web_dialog"]
	else
		raise "Incorrect Design Assistant version '#{args[:version]}'" if args[:version] != "html_dialog" and args[:version] != "web_dialog"
		versions = [args[:version]]
	end

	versions.each{|version|
		# Change version
		change_ui_version(version)

		# Set DEV to false
		set_is_dev(false)

		# Generate
		Dir.chdir(@ui_src){
			# Generate a dist folder with the compiled
			warn `npm run generate` 		
		}

		# Replace javascript fileutils
		FileUtils.rm_rf("#{destination}/#{version}/design_assistant")
		FileUtils.cp_r("#{@ui_src}/dist","#{destination}/#{version}/design_assistant")
	}
	set_is_dev(true)

end
