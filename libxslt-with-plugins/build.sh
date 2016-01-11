DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
xcodebuild -sdk iphoneos
xcodebuild -sdk watchos
xcodebuild -sdk iphonesimulator

lipo -create \
build/Release-watchos/libxslt-with-plugins.a \
build/Release-iphoneos/libxslt-with-plugins.a \
build/Release-iphonesimulator/libxslt-with-plugins.a \
-output libxslt-with-plugins.a