//
//  XHTest.m
//  XHTest
//
//  Created by Eugene Dorfman on 10/15/14.
//
//

#import <XCTest/XCTest.h>
#import "XHTransformation.h"

@interface XHTransformationTest : XCTestCase
@end

@implementation XHTransformationTest

- (void)processAdSearchHTMLWithTransformation:(XHTransformation *)transformation {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *adsearchHTMLPath = [bundle pathForResource:@"adsearch" ofType:@"html"];
    NSError *error = nil;
    NSString *html = [NSString stringWithContentsOfFile:adsearchHTMLPath encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *dict = [transformation JSONObjectFromHTML:html withParams:@{@"CLURL":@"'http://losangeles.craigslist.org'"} error:&error];
    XCTAssertNotNil(dict);
    if (dict) {
        NSArray *ads = dict[@"ads"];
        XCTAssertEqual(ads.count, 100);
        XCTAssertEqualObjects(dict[@"linkNext"], @"http://losangeles.craigslist.org/search/sss?s=100&amp;");
        
        NSDictionary *ad = ads[0];
        /*

         date = "Sep 28";
         link = "http://losangeles.craigslist.org/wst/hab/4654643751.html";
         location = ManhattanBeach;
         postingID = 4654643751;
         price = "$45";
         thumbnail = "http://images.craigslist.org/01010_75NCSod5uST_300x300.jpg";
         title = "Genco Wedge straight razor shave ready";

         */
        
        //this also tests passing CLURL as a parameter:
        XCTAssertEqualObjects(ad[@"link"], @"http://losangeles.craigslist.org/wst/hab/4654643751.html");
        XCTAssertEqualObjects(ad[@"thumbnail"], @"http://images.craigslist.org/01010_75NCSod5uST_300x300.jpg");
        XCTAssertEqualObjects(ad[@"postingID"], @"4654643751");
    } else {
        XCTFail(@"failed to transformHTML: %@",error);
    }
}

- (void)testInitWithURL {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *adsearchXSLPath = [bundle pathForResource:@"adsearch" ofType:@"xsl"];
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:[NSURL fileURLWithPath:adsearchXSLPath]];
    [self processAdSearchHTMLWithTransformation:transformation];
}

- (void) testInitWithXSLString {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *adsearchXSLPath = [bundle pathForResource:@"adsearch" ofType:@"xsl"];
    NSError *error = nil;
    NSString *xsl = [NSString stringWithContentsOfFile:adsearchXSLPath encoding:NSUTF8StringEncoding error:&error];
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTString:xsl baseURL:[NSURL fileURLWithPath:adsearchXSLPath]];

    [self processAdSearchHTMLWithTransformation:transformation];
}

- (void) testInclude {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *testIncludeXSLPath = [bundle pathForResource:@"testinclude" ofType:@"xsl"];
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:[NSURL fileURLWithPath:testIncludeXSLPath]];
    [self processAdSearchHTMLWithTransformation:transformation];
    
    NSError *error = nil;
    NSString *testinclude = [NSString stringWithContentsOfFile:testIncludeXSLPath encoding:NSUTF8StringEncoding error:&error];
    XHTransformation *transformation2 = [[XHTransformation alloc] initWithXSLTString:testinclude baseURL:[NSURL fileURLWithPath:testIncludeXSLPath]];
    [self processAdSearchHTMLWithTransformation:transformation2];
}

- (void) testFormParsing {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *postformXSLPath = [bundle pathForResource:@"postform" ofType:@"xsl"];
    NSError *error = nil;
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:[NSURL fileURLWithPath:postformXSLPath]];
    
    NSString *postformHTMLPath = [bundle pathForResource:@"postform" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:postformHTMLPath encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *form = [transformation JSONObjectFromHTML:html withParams:@{@"CLURL":@"'http://losangeles.craigslist.org'"} error:&error];
    NSLog(@"%@",form);
    XCTAssertNotNil(form);
    XCTAssertEqualObjects(form[@"form_action"],@"https://post.craigslist.org/k/5PggyFxH5BGkB8vLjhH61A/h0SwJ");
    XCTAssertEqual([form[@"fields"] count], 11);
    NSDictionary *fieldset0 = form[@"fields"][0];
    XCTAssertEqualObjects(fieldset0[@"display_name"], @"contact info");
    
    NSDictionary *field1 = fieldset0[@"fields"][1];
    /*
     {
     "is_error" = 0;
     "is_required" = 1;
     name = FromEMail;
     type = text;
     value = "Your email address";
     }
     */
    XCTAssertEqualObjects(field1[@"name"], @"FromEMail");
    XCTAssertEqualObjects(field1[@"type"], @"text");
    XCTAssertEqualObjects(field1[@"value"], @"Your email address");
    XCTAssertEqualObjects(field1[@"is_error"], @0);
    XCTAssertEqualObjects(field1[@"is_required"], @1);
}

@end
