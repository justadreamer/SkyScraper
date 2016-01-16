CHANGELOG
=========
## 0.35
fixed imports of other headers in the SkyScraper.h, it now includes only headers needed for the Base subspec.  
other subspecs (+AFNetworking, +Mantle) have their own designated headers.  
this is a breaking change for the clients that used AFNetworking and Mantle subspecs - they will now have to explicitly export SkyScraper+AFNetworking.h, SkyScraper+Mantle.h correspondingly to use those features.

## 0.34
Fixed fat binary simulator slices in libxslt-with-plugins.a

## 0.33
Supporting CocoaPods integration as a dynamic framework (w/ use_frameworks! in Podfile) or as a static library.  The former is needed if you integrate other CocoaPods dependencies, which contain Swift code.

