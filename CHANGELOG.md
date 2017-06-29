CHANGELOG
=========
## 0.42
update [SkyJSONResponseSerializer.applyTransformationToData:withError:] so it can work with JSON input as well

## 0.41
make SkyXSLTransformation properties atomic, so that we synchronize access to them by default

## 0.40
convert NSData to NSString - fixed

## 0.39
check result string on zero length on the first pass

## 0.38
added Mac OS X 10.10 as a deployment target

## 0.37
move to gitlab repos

## 0.36
avoid possible crashes if we can’t recognize a content string

## 0.35
fixed imports of other headers in the SkyScraper.h, it now includes only headers needed for the Base subspec.  
other subspecs (+AFNetworking, +Mantle) have their own designated headers.  
this is a breaking change for the clients that used AFNetworking and Mantle subspecs - they will now have to explicitly export SkyScraper+AFNetworking.h, SkyScraper+Mantle.h correspondingly to use those features.

## 0.34
Fixed fat binary simulator slices in libxslt-with-plugins.a

## 0.33
Supporting CocoaPods integration as a dynamic framework (w/ use_frameworks! in Podfile) or as a static library.  The former is needed if you integrate other CocoaPods dependencies, which contain Swift code.

