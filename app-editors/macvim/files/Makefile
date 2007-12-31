CC=gcc
CFLAGS=
PSMTabBarControlDir=PSMTabBarControl/source
PSMTabBarControlObjects=\
	$(PSMTabBarControlDir)/NSBezierPath_AMShading.m	\
	$(PSMTabBarControlDir)/PSMAquaTabStyle.m		\
	$(PSMTabBarControlDir)/PSMMetalTabStyle.m		\
	$(PSMTabBarControlDir)/PSMOverflowPopUpButton.m	\
	$(PSMTabBarControlDir)/PSMProgressIndicator.m	\
	$(PSMTabBarControlDir)/PSMRolloverButton.m		\
	$(PSMTabBarControlDir)/PSMTabBarCell.m			\
	$(PSMTabBarControlDir)/PSMTabBarControl.m		\
	$(PSMTabBarControlDir)/PSMTabDragAssistant.m	\
	$(PSMTabBarControlDir)/PSMUnifiedTabStyle.m

MacVimObjects=$(PSMTabBarControlDir)/PSMTabBarControl \
	main.m				\
	MacVim.m			\
	MMAppController.m	\
	MMTextStorage.m		\
	MMTextView.m		\
	MMVimController.m	\
	MMWindowController.m\
	MMTypesetter.m		\
	MMApplication.m		\
	MMFullscreenWindow.m\
	MMVimView.m			\

TARGET=@GENTOO_PORTAGE_EPREFIX@/usr/share/macvim

all: app

framework:
	$(CC) $(CFLAGS) -o $(PSMTabBarControlDir)/PSMTabBarControl -framework Cocoa -dynamiclib -install_name @executable_path/../Frameworks/PSMTabBarControl.framework/Versions/A/PSMTabBarControl $(PSMTabBarControlObjects)

macvim: framework
	$(CC) $(CFLAGS) -o MacVim -framework Cocoa -framework Carbon -I$(PSMTabBarControlDir) $(MacVimObjects)

app: framework macvim
	@# binaries
	@mkdir -p MacVim.app/Contents/MacOS
	@cp MacVim ../Vim MacVim.app/Contents/MacOS
	@sed -e 's/$${EXECUTABLE_NAME}/MacVim/' -e 's/$${PRODUCT_NAME}/MacVim/'  Info.plist > MacVim.app/Contents/Info.plist 
	@# headers
	@mkdir -p PSMTabBarControl.framework/Versions/A/Headers
	@cp PSMTabBarControl/source/PSMTabBarControl.h PSMTabBarControl.framework/Versions/A/Headers
	@# resources
	@mkdir -p MacVim.app/Contents/Resources/vim
	@ln -s @GENTOO_PORTAGE_EPREFIX@/usr/share/vim/vim71 MacVim.app/Contents/Resources/vim/runtime
	@cp {g,}vimrc MacVim.app/Contents/Resources/vim
	@cp *.{plist,icns} MacVim.app/Contents/Resources
	@cp Toolbar/*.png MacVim.app/Contents/Resources
	@mkdir -p MacVim.app/Contents/Resources/English.lproj
	@cp -r English.lproj/MainMenu.nib MacVim.app/Contents/Resources/English.lproj
	@cp dejavu-ttf-2.20/*.ttf MacVim.app/Contents/Resources
	@echo APPLVIMM > MacVim.app/Contents/PkgInfo
	@### PSMTabBarControl
	@# binaries
	@cp PSMTabBarControl/source/PSMTabBarControl PSMTabBarControl.framework/Versions/A
	@# resources
	@mkdir -p PSMTabBarControl.framework/Versions/A/Resources
	@cp PSMTabBarControl/images/AquaTab* PSMTabBarControl.framework/Versions/A/Resources
	@cp PSMTabBarControl/images/Tab* PSMTabBarControl.framework/Versions/A/Resources
	@cp PSMTabBarControl/images/overflow* PSMTabBarControl.framework/Versions/A/Resources
	@cp PSMTabBarControl/images/pi.png PSMTabBarControl.framework/Versions/A/Resources
	@cp PSMTabBarControl/Info.plist PSMTabBarControl.framework/Versions/A/Resources
	@# frameworks
	@mkdir MacVim.app/Contents/Frameworks
	@mv PSMTabBarControl.framework MacVim.app/Contents/Frameworks
	@# links
	@ln -s Versions/A/PSMTabBarControl MacVim.app/Contents/Frameworks/PSMTabBarControl.framework/PSMTabBarControl
	@ln -s Versions/Current/Headers MacVim.app/Contents/Frameworks/PSMTabBarControl.framework/Headers
	@ln -s Versions/Current/Resources MacVim.app/Contents/Frameworks/PSMTabBarControl.framework/Resources
	@ln -s A MacVim.app/Contents/Frameworks/PSMTabBarControl.framework/Versions/Current 

clean:
	@rm -rf MacVim.app

install:
	install -d $(DESTDIR)$(TARGET)
	cp -r MacVim.app $(DESTDIR)$(TARGET)
