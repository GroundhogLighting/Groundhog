SKETCHUP_PLUGIN_DIR=~/Library/Application\ Support/SketchUp\ 2016/SketchUp/Plugins
GH_DESTINATION=./IGD_Groundhog/src/Radiance
CLEAN_DESTINATION=rm -rf $(GH_DESTINATION)/*

publish:
	@read -p "Enter commit message:" message; \
	commit_message=$$message; \
	git add .
	git commit -m \"$$commitmessage\"
	

aa:
	@read -p "Enter commit message:" commitmessage; \
	git add .
	git commit -m \"$$commitmessage\"
	git push


all: win32 win64 macosx

doc:
	rm -rf doc
	yardoc IGD_Groundhog/src/*.rb - Readme.md
	rm -fr IGD_Groundhog/doc
	cp -rf doc IGD_Groundhog/doc

clean:
	rm -f *.rbz


test: macosx
	cp -r IGD_Groundhog.rb $(SKETCHUP_PLUGIN_DIR)/IGD_Groundhog.rb
	cp -r IGD_Groundhog $(SKETCHUP_PLUGIN_DIR)/IGD_Groundhog

macosx: clean doc
	$(CLEAN_DESTINATION)
	cp -r Radiance/macosx/usr/local/radiance/* $(GH_DESTINATION)
	zip -r Groundhog_macosx.rbz IGD_Groundhog IGD_Groundhog.rb -x *yardoc* *.DS_Store
	$(CLEAN_DESTINATION)

win32: clean doc
	$(CLEAN_DESTINATION)
	cp -r Radiance/win32/Radiance/* $(GH_DESTINATION)
	zip -r Groundhog_win32.rbz IGD_Groundhog IGD_Groundhog.rb -x *yardoc* *.DS_Store
	$(CLEAN_DESTINATION)

win64: clean doc
	$(CLEAN_DESTINATION)
	cp -r Radiance/win64/Radiance/* $(GH_DESTINATION)
	zip -r Groundhog_win64.rbz IGD_Groundhog IGD_Groundhog.rb -x *yardoc* *.DS_Store
	$(CLEAN_DESTINATION)
