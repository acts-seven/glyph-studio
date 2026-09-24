.PHONY: all test build build-ios package install deploy clean

DEVELOPER_DIR ?= /Applications/Xcode-beta.app/Contents/Developer
export DEVELOPER_DIR
XCODEBUILD := xcodebuild
RELEASE_DIR := release
DERIVED_DATA := build/derivedData

all: test build package

test:
	$(XCODEBUILD) test -scheme GLYPHCoreTests -destination 'platform=macOS'

build:
	$(XCODEBUILD) build -scheme GLYPHApp -configuration Release -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA)

build-ios:
	$(XCODEBUILD) build -scheme GLYPHKeyboard -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO -derivedDataPath $(DERIVED_DATA)

package: build
	@mkdir -p $(RELEASE_DIR)
	@rm -rf "$(RELEASE_DIR)/GLYPH Studio.app"
	cp -R "$(DERIVED_DATA)/Build/Products/Release/GLYPHApp.app" "$(RELEASE_DIR)/GLYPH Studio.app"
	@mkdir -p "$(RELEASE_DIR)/GLYPH Studio.app/Contents/Resources"
	cp assets/AppIcon.icns "$(RELEASE_DIR)/GLYPH Studio.app/Contents/Resources/AppIcon.icns"
	plutil -replace CFBundleIconFile -string "AppIcon" "$(RELEASE_DIR)/GLYPH Studio.app/Contents/Info.plist"
	codesign --force --sign - --timestamp=none "$(RELEASE_DIR)/GLYPH Studio.app"
	cd $(RELEASE_DIR) && rm -f GLYPH-Studio-v1.0.0-macOS.zip checksums.txt
	cd $(RELEASE_DIR) && zip -r -y GLYPH-Studio-v1.0.0-macOS.zip "GLYPH Studio.app"
	cd $(RELEASE_DIR) && shasum -a 256 GLYPH-Studio-v1.0.0-macOS.zip > checksums.txt
	@echo "Package created in $(RELEASE_DIR)/"

install: package
	@rm -rf "/Applications/GLYPH Studio.app"
	cp -R "$(RELEASE_DIR)/GLYPH Studio.app" "/Applications/GLYPH Studio.app"
	@echo "Successfully installed GLYPH Studio.app into /Applications/"

pkg:
	chmod +x script/build_pkg.sh
	./script/build_pkg.sh

deploy: install pkg
	@echo "Deployment complete."

clean:
	rm -rf $(RELEASE_DIR) $(DERIVED_DATA)
