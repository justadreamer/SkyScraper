//
//  SkyScraperTest.m
//  SkyScraperTest
//
//  Created by Eugene Dorfman on 10/15/14.
//
//

#import <XCTest/XCTest.h>
#import <SkyScraper/SkyScraper.h>
#import <AFNetworking/AFNetworking.h>
#import "AdData.h"
#import "AdDataContainer.h"
#import "Nocilla.h"

@interface SkyXSLTransformation (Private)
- (NSString*) replaceEntities:(NSString*)string isHTML:(BOOL)isHTML;
@end

@interface SkyScraperTest : XCTestCase
@end

#define kAdJsonSearch_URL   @"http://sfbay.craigslist.org/jsonsearch/hhh"
#define kIPBlock_URL        @"http://sfbay.craigslist.org"

@implementation SkyScraperTest

- (void) setUp {
    [super setUp];
    [[LSNocilla sharedInstance] start];
}

- (void) tearDown {
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
    [super tearDown];
}

- (void)processAdSearchHTMLWithTransformation:(SkyXSLTransformation *)transformation {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *adsearchHTMLPath = [bundle pathForResource:@"adsearch" ofType:@"html"];
    NSError *error = nil;
    NSData *html = [NSData dataWithContentsOfFile:adsearchHTMLPath];
    NSDictionary *dict = [transformation JSONObjectFromHTMLData:html withParams:@{@"CLURL":@"'http://losangeles.craigslist.org'"} error:&error];
    XCTAssertNotNil(dict);
    if (dict) {
        NSArray *ads = dict[@"ads"];
        XCTAssertEqual(ads.count, 100);
        XCTAssertEqualObjects(dict[@"linkNext"], @"http://losangeles.craigslist.org/search/sss?s=100&");
        
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
    NSURL *adsearchXSLURL = [bundle URLForResource:@"adsearch" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:adsearchXSLURL];
    [self processAdSearchHTMLWithTransformation:transformation];
}

- (void) testInitWithXSLString {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *adsearchXSLPath = [bundle pathForResource:@"adsearch" ofType:@"xsl"];
    NSError *error = nil;
    NSString *xsl = [NSString stringWithContentsOfFile:adsearchXSLPath encoding:NSUTF8StringEncoding error:&error];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTString:xsl baseURL:[NSURL fileURLWithPath:adsearchXSLPath]];

    [self processAdSearchHTMLWithTransformation:transformation];
}

- (void) testInclude {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *testIncludeXSLPath = [bundle pathForResource:@"testinclude" ofType:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:[NSURL fileURLWithPath:testIncludeXSLPath]];
    [self processAdSearchHTMLWithTransformation:transformation];
    
    NSError *error = nil;
    NSString *testinclude = [NSString stringWithContentsOfFile:testIncludeXSLPath encoding:NSUTF8StringEncoding error:&error];
    SkyXSLTransformation *transformation2 = [[SkyXSLTransformation alloc] initWithXSLTString:testinclude baseURL:[NSURL fileURLWithPath:testIncludeXSLPath]];
    [self processAdSearchHTMLWithTransformation:transformation2];
}

- (void) testFormParsing {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *postformXSLPath = [bundle pathForResource:@"postform" ofType:@"xsl"];
    NSError *error = nil;
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:[NSURL fileURLWithPath:postformXSLPath]];
    
    NSString *postformHTMLPath = [bundle pathForResource:@"postform" ofType:@"html"];
    NSData *html = [NSData dataWithContentsOfFile:postformHTMLPath];
    NSDictionary *form = [transformation JSONObjectFromHTMLData:html withParams:@{@"CLURL":@"'http://losangeles.craigslist.org'"} error:&error];
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

- (void) testArrayOfModels {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *postformXSLPath = [bundle pathForResource:@"adsarray" ofType:@"xsl"];
    NSError *error = nil;
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:[NSURL fileURLWithPath:postformXSLPath]];
    
    NSString *postformHTMLPath = [bundle pathForResource:@"adsearch" ofType:@"html"];
    NSData *html = [NSData dataWithContentsOfFile:postformHTMLPath];
    NSArray *ads = [transformation JSONObjectFromHTMLData:html withParams:@{@"CLURL":@"'http://losangeles.craigslist.org'"} error:&error];
    
    SkyMantleModelAdapter *modelAdapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[AdData class]];

    NSArray *models = [modelAdapter modelFromJSONObject:ads error:&error];
    XCTAssertNotNil(models);
    XCTAssertEqual([models count], [ads count]);
    AdData *adData = models[0];
    XCTAssertNotNil(adData.title);
    XCTAssertNotNil(adData.postingID);
    XCTAssertEqualObjects(adData.title, ads[0][@"title"]);
    XCTAssertEqualObjects(adData.postingID, ads[0][@"postingID"]);
}

- (void) testReplacingEntities {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *entitiesXSLURL = [bundle URLForResource:@"entities" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:entitiesXSLURL];
    
    NSString *entitiexHTMLPath = [bundle pathForResource:@"entities" ofType:@"html"];
    NSData *html = [NSData dataWithContentsOfFile:entitiexHTMLPath];
    NSError *error = nil;
    NSDictionary *result = [transformation JSONObjectFromHTMLData:html withParams:nil error:&error];
    
    XCTAssertNotNil(result);
    
    XCTAssertEqualObjects(result[@"link"], @"http://losangeles.craigslist.org/?param=1&param=2");
    XCTAssertEqualObjects(result[@"text"], @"test1 & test2");
}

- (void) runRegexpFunctionTest:(NSString *)functionName {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *xslURL = [bundle URLForResource:functionName withExtension:@"xsl"];
    NSString *htmlPath = [bundle pathForResource:functionName ofType:@"xml"];
    
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:xslURL];
    
    
    NSData *html = [NSData dataWithContentsOfFile:htmlPath];
    
    NSString *actual = [transformation stringFromHTMLData:html withParams:nil error:nil];
    
    NSString *outPath = [bundle pathForResource:functionName ofType:@"out"];
    NSString *expected = [NSString stringWithContentsOfFile:outPath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertEqualObjects(actual, expected);
}

- (void) testRegexp {
    [self runRegexpFunctionTest:@"test"];
    [self runRegexpFunctionTest:@"match"];
    [self runRegexpFunctionTest:@"replace"];
}

- (void) testXMLTransformation {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *xslURL = [bundle URLForResource:@"search_rss" withExtension:@"xsl"];
    
    NSURL *xmlURL = [bundle URLForResource:@"hhh" withExtension:@"xml"];
    
    NSData *xml = [NSData dataWithContentsOfURL:xmlURL];
    
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:xslURL];
    
    NSError *error = nil;
    id json = [transformation JSONObjectFromXMLData:xml withParams:nil error:&error];
    
    XCTAssertNotNil(json);
    XCTAssertTrue([json[@"title"] length]>0);
    XCTAssertEqualObjects(json[@"title"], @"WHY PAY YOUR LANDLORD'S MORTGAGE!!! BE A FIRST TIME HOME BUYER!!! 3bd 1600ft<sup>2</sup>");
    
    NSString *s  = [transformation stringFromXMLData:xml withParams:nil error:&error];
    
    XCTAssertNotNil(s);
    XCTAssertTrue([s length]>0);
    XCTAssertTrue([s containsString:@"WHY PAY YOUR LANDLORD'S MORTGAGE!!!"]);
}

- (void) testErrorHandling {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:kIPBlock_URL]];
    stubRequest(@"GET", kIPBlock_URL).andFailWithError([NSError errorWithDomain:@"Forbidden" code:403 userInfo:nil]);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:[[NSBundle bundleForClass:self.class] URLForResource:@"adsearch" withExtension:@"xsl"]];
    SkyMantleModelAdapter *modelAdapter = [[SkyMantleModelAdapter alloc] initWithModelClass:AdDataContainer.class];
    operation.responseSerializer = [SkyJSONResponseSerializer serializerWithXSLTransformation:transformation params:nil modelAdapter:modelAdapter];
    XCTestExpectation *expectation = [self expectationWithDescription:@"load_error"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, AdDataContainer* adDataContainer) {
        XCTFail(@"nu success in this case, it should return 403 error");
        [expectation fulfill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        XCTAssertEqual(error.code, 403,@"error code should be 403");
        [expectation fulfill];
    }];
    [operation start];
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        if (error) XCTFail(@"%@",error.localizedDescription);
    }];

}

- (void) testJSONTransformation {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *xslURL = [bundle URLForResource:@"search_map" withExtension:@"xsl"];
    
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:kAdJsonSearch_URL]];
    NSString* path = [bundle pathForResource:@"adjsonsearch" ofType:@"json"];
    stubRequest(@"GET", kAdJsonSearch_URL).andReturnRawResponse([NSData dataWithContentsOfFile:path]).withHeaders(@{@"Content-Type": @"application/json"});
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:xslURL];
    SkyMantleModelAdapter *modelAdapter = [[SkyMantleModelAdapter alloc] initWithModelClass:AdDataContainer.class];
    operation.responseSerializer = [SkyJSONResponseSerializer serializerWithXSLTransformation:transformation params:nil modelAdapter:modelAdapter];
    XCTestExpectation *expectation = [self expectationWithDescription:@"load_json"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, AdDataContainer* adDataContainer) {
        XCTAssertNotNil(adDataContainer);
        XCTAssertTrue(adDataContainer.ads.count>0);
        NSUInteger adsWithPrice = 0;
        for (AdData* adData in adDataContainer.ads) {
            XCTAssertTrue(adData.postingID.length>0);
            XCTAssertTrue(adData.title.length>0);
            XCTAssertNotNil(adData.URL);
            if (adData.price.length>0) {
                adsWithPrice++;
            }
        }
        XCTAssertTrue(adsWithPrice>0);
        [expectation fulfill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        XCTFail(@"%@",error.localizedDescription);
        [expectation fulfill];
    }];
    [operation start];
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        if (error) XCTFail(@"%@",error.localizedDescription);
    }];
}

#pragma mark - check bad UTF-8 encoding & XML entities

- (void) testXMLEntitiesReplcing {
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:nil];
    NSString* string = @"&#x20B4&amp;&quot;&apos;&lt;&gt;&#1090;&#1077;&#1082;&#1089;&#1090;&#x20B4";
    NSString* stringWithCDATA = [string stringByAppendingFormat:@"<![CDATA[%@]]> <![CDATA[%@]]>",string,string];
    XCTAssertEqualObjects([transformation replaceEntities:string isHTML:YES],
                          @"₴&amp;&quot;&apos;&lt;&gt;текст₴");
    XCTAssertEqualObjects([transformation replaceEntities:stringWithCDATA isHTML:YES],
                          @"₴&amp;&quot;&apos;&lt;&gt;текст₴<![CDATA[₴&amp;&quot;&apos;&lt;&gt;текст₴]]> <![CDATA[₴&amp;&quot;&apos;&lt;&gt;текст₴]]>");
    XCTAssertEqualObjects([transformation replaceEntities:string isHTML:NO],
                          @"₴&amp;&quot;&apos;&lt;&gt;текст₴");
    XCTAssertEqualObjects([transformation replaceEntities:stringWithCDATA isHTML:NO],
                          @"₴&amp;&quot;&apos;&lt;&gt;текст₴<![CDATA[₴&\"'<>текст₴]]> <![CDATA[₴&\"'<>текст₴]]>");
}

- (void) testBadXMLEncoding {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *xslURL = [bundle URLForResource:@"search_rss" withExtension:@"xsl"];
    NSURL *xmlURL = [bundle URLForResource:@"bad_utf8" withExtension:@"xml"];
    NSData *xml = [NSData dataWithContentsOfURL:xmlURL];
    
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:xslURL];
    transformation.replaceXMLEntities = YES;
    
    NSError *error = nil;
    id json = [transformation JSONObjectFromXMLData:xml withParams:nil error:&error];
    
    XCTAssertNil(error);
    XCTAssertEqualObjects(json[@"title"], @"WoW! Look At Me! ★ Big Beautiful Studio ★ Paid Utilities! (&\"'<>текст₴) (Highland Park South Pasadena Eagle Rock) $1350"); // inside CDATA
    XCTAssertEqualObjects(json[@"rights"], @"© 2015 (&\"'<>текст₴)"); // outside CDATA
}

- (void) testBadHTMLEncoding {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *xslURL = [bundle URLForResource:@"adsearch" withExtension:@"xsl"];
    NSURL *htmlURL = [bundle URLForResource:@"bad_utf8" withExtension:@"html"];
    NSData *html = [NSData dataWithContentsOfURL:htmlURL];
    
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:xslURL];
    transformation.replaceXMLEntities = YES;
    
    NSError *error = nil;
    id json = [transformation JSONObjectFromHTMLData:html withParams:@{@"CLURL":@"'http://losangeles.craigslist.org'"} error:&error];
    
    XCTAssertNil(error);
    NSDictionary* adData = [json[@"ads"] firstObject];
    XCTAssertNotNil(adData);
    XCTAssertEqualObjects(adData[@"title"], @"© WoW! Look At Me! Big Beautiful Studio Paid Utilities! (&\"'<>текст₴)");
}

@end
