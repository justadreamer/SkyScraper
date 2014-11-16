SkyScraper is an advanced web scraping library for iOS written in Objective-C.  It is specifically designed to allow HTML document parsing and conversion into JSON model representation (and then further into the application objects).  The mapping of the specific parts of HTML document to JSON model representation is defined by the end user in XSLT 1.0 langugage.

The library is an [XSLT](https://en.wikipedia.org/wiki/XSLT) 1.0 processor based on [libxslt](http://xmlsoft.org/libxslt/) (primarily by Daniel Veillard) with some built-in [EXSLT](http://exslt.org) extensions - shipping within [libexslt](http://www.xmlsoft.org/XSLT/EXSLT/index.html) as part of libxslt, and an external [regexp extension](http://exslt.org/regexp/index.html) by Joel W. Reed.


## GENERAL IDEA

The idea of web scraping is to acquire data from HTML documents that are hosted on the web.  It can be done in various ways - most of which are based on  (SAX, DOM) parsing of HTML and then extracting the needed data for corresponding fields of application-specific data models.  
For iOS usually it is done within the application code - thus hardcoding the parsing logic and mixing it into the application logic.  
The classical approach makes it hard to modify the parsing logic independently and hard to automate and generalize conversion into the application data models.  
Instead SkyScraper abstracts the HTML-parsing and data-extraction logic by use of XSLT files that are separate from the application code, and define the conversion of HTML into JSON, which contains the extracted pieces of data to be then easily deserialized into application-specific data objects (using such frameworks as f.e. [Mantle](https://github.com/Mantle/Mantle))

So the basic scheme is like this:  HTML -> SkyXSLTransformation -> JSON -> ModelDeserializationFramework -> Model

See the Rationale section which justifies this approach.

## HOW TO START

**1)** Prior to integrating into your own project - it is recommended to checkout and study the Tests project and Examples/CLSkyScraper project contained within this repository.  After cloning please cd into Tests and Examples/CLSkyScraper and run 

	pod install
	
within those directories, since the Pods are not under git for the Tests and Examples.  After the pods are installed open respectively:
	
	Tests.xcworkspace
	
and 
	
	CLSkyScraper.xcworkspace


**2)** The recommended way of integration into your own project is by using the [CocoaPods](http://cocoapods.org).  The Podspec is for now contained within this repository, so please add this into the Podfile:

	pod 'SkyScraper', :git => "git@github.com:justadreamer/SkyScraper.git"

This includes the additions for the AFNetworking and Mantle frameworks.  If you don't use/want those, please use:

	pod 'SkyScraper/Base', :git => "git@github.com:justadreamer/SkyScraper.git"

This includes only the SkyXSLTransformation class. 

The spec will be moved into the main Specs repository eventually, but for now the library is in its early testing stage.

**3)**  To learn/train yourself in XSLT - again please study the Tests and Examples/CLSkyScraper projects - there are XSLT transformations defined within the application resources.  There are some useful tricks to be learned from these examples - f.e. modularization by utilizing XIncludes, text data sanitization to be used within JSON, URL concatenation, etc.  There are also quite a lot of resources on XSLT 1.0 on the web:

[https://en.wikipedia.org/wiki/XSLT](https://en.wikipedia.org/wiki/XSLT)

[http://www.w3.org/TR/xslt](http://www.w3.org/TR/xslt)

[http://www.w3schools.com/xsl/default.asp](http://www.w3schools.com/xsl/default.asp)


##Example of direct usage
Below is an example boilerplace code needed to apply an XSLT transformation and get a JSON from an HTML data.  We assume that you have got an HTML document represented with ```NSData *html``` object and have an XSLT transformation ```scraping.xsl``` in the application resources:

	NSBundle *bundle = [NSBundle bundleForClass:self.class];
	NSURL *XSLURL = [bundle URLForResource:@"scraping" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    
	id result = [transformation JSONObjectFromHTMLData:html withParams:nil error:&error];
	NSLog(@"%@",result);
	


##Example usage with AFNetworking '~> 2'
Below is an example boilerplate code you need to download the HTML document and acquire the JSON representation of your application data models.  It is assumed that you have defined an ```NSURL *URL``` object pointing at target HTML document on the web.  It is also assumed that somewhere in the application resource bundle you have ```scraping.xsl``` file with the XSLT transformation to convert HTML into JSON.

		#import <SkyScraper/SkyScraper.h>
		//...
		
	    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	    
	    NSURL *localXSLURL = [[NSBundle mainBundle] URLForResource:@"scraping" withExtension:@"xsl"];
	    
	    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:localXSLURL];
	    
	    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:nil modelAdapter:nil];
	    
	    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	    operation.responseSerializer = serializer;

	    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
	        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        	NSLog(@"%@",error);
        }];
    	
    	[operation start];
    	
    	
Here the transformation object has been utilized within the response serializer object, used by AFHTTPRequestOperation to deserialize the response.