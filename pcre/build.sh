xcodebuild -sdk iphoneos
xcodebuild -sdk iphonesimulator
lipo -create build/Release-iphoneos/libpcre.a build/Release-iphonesimulator/libpcre.a -output libpcre.a
