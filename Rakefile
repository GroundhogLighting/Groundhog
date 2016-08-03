require 'fileutils'

task :default => :all

task :all => [:win32, :win64, :macosx] do
	FileUtils.rm_rf "./IGD_Groundhog/src/Radiance"
end

task :doc => [:clean] do
	puts `yardoc IGD_Groundhog/src/*.rb IGD_Groundhog/src/Scripts/*.rb - Readme.md`
	FileUtils.rm_rf("IGD_Groundhog/doc")
	FileUtils.cp_r("doc","IGD_Groundhog/doc")
end

task :clean do
	FileUtils.rm(Dir["*.rbz"])
	FileUtils.rm_rf("doc")
end

sketchup_plugin_dir = "#{ENV["UserProfile"].gsub("\\","/")}/AppData/Roaming/SketchUp/SketchUp 2016/SketchUp/Plugins"

task :test => [:win64] do
	FileUtils.rm_rf "#{sketchup_plugin_dir}/IGD_Groundhog.rb"
	FileUtils.rm_rf "#{sketchup_plugin_dir}/IGD_Groundhog"
	FileUtils.cp_r "IGD_Groundhog.rb","#{sketchup_plugin_dir}/IGD_Groundhog.rb"
	FileUtils.cp_r "IGD_Groundhog","#{sketchup_plugin_dir}/IGD_Groundhog"	
	FileUtils.rm_rf("./IGD_Groundhog/src/Radiance")
end


def compress(os)
	radiance_version = "Radiance/#{os}/Radiance"
	radiance_version = "Radiance/macosx/usr/local/radiance" if os == "macosx"
	File.open("listfile.txt",'w'){|w|
		w.puts "IGD_Groundhog.rb"
		w.puts "IGD_Groundhog"
	}
	FileUtils.rm_rf("./IGD_Groundhog/src/Radiance")
	FileUtils.cp_r radiance_version, "./IGD_Groundhog/src/Radiance"
	puts `7z a -tzip Groundhog_#{os}.rbz @listfile.txt -x!.yardoc -x!*.DS_Store `
	FileUtils.rm "listfile.txt"
end

task :win64 => [:clean, :doc] do
	compress("win64")
end
task :win32 => [:clean, :doc] do
	compress("win32")
end
task :macosx => [:clean, :doc] do
	compress("macosx")
end
