SKETCHUP_PLUGIN_DIR=~/Library/Application\ Support/SketchUp\ 2016/SketchUp/Plugins
GH_DESTINATION=./IGD_Groundhog/src/Radiance
CLEAN_DESTINATION=rm -rf $(GH_DESTINATION)/*


publish: all
	git add . ;\
	git commit -m "automatic commit, built doc, wrapped RBZ, and pushed";
	git push

all: win32 win64 macosx
<<<<<<< Updated upstream
	$(CLEAN_DESTINATION)
=======
>>>>>>> Stashed changes

doc:
	rm -rf doc
	yardoc IGD_Groundhog/src/*.rb - Readme.md
	rm -fr IGD_Groundhog/doc
	cp -rf doc IGD_Groundhog/doc

clean:
	rm -f *.rbz

test: macosx
	rm -rf $(SKETCHUP_PLUGIN_DIR)/IGD_Groundhog.rb
	rm -rf $(SKETCHUP_PLUGIN_DIR)/IGD_Groundhog
	cp -rf IGD_Groundhog.rb $(SKETCHUP_PLUGIN_DIR)/IGD_Groundhog.rb
	cp -rf IGD_Groundhog $(SKETCHUP_PLUGIN_DIR)/IGD_Groundhog
	$(CLEAN_DESTINATION)

macosx: clean doc
	$(CLEAN_DESTINATION)
	cp -r Radiance/macosx/usr/local/radiance/* $(GH_DESTINATION)
	zip -r Groundhog_macosx.rbz IGD_Groundhog IGD_Groundhog.rb -x *yardoc* *.DS_Store

win32: clean doc
	$(CLEAN_DESTINATION)
	cp -r Radiance/win32/Radiance/* $(GH_DESTINATION)
	zip -r Groundhog_win32.rbz IGD_Groundhog IGD_Groundhog.rb -x *yardoc* *.DS_Store

win64: clean doc
	$(CLEAN_DESTINATION)
	cp -r Radiance/win64/Radiance/* $(GH_DESTINATION)
	zip -r Groundhog_win64.rbz IGD_Groundhog IGD_Groundhog.rb -x *yardoc* *.DS_Store
