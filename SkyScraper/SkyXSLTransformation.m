#include <string.h>
#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLparser.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/DOCBparser.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include "xslt.h"
#include "xsltInternals.h"
#include "transform.h"
#include "xsltutils.h"
#include "exslt.h"

#import "SkyXSLTransformation.h"
#import "SkyXSLTParams.h"

NSString  * const SkyScraperErrorDomain = @"SkyScraperErrorDomain Error Domain";

extern int xmlLoadExtDtdDefaultValue;

@interface SkyXSLTransformation()
@property (nonatomic,assign) xsltStylesheetPtr stylesheet;
@end

void exslt_org_regular_expressions_init();

@implementation SkyXSLTransformation
- (void) dealloc {
    xsltFreeStylesheet(self.stylesheet);
}

+ (void)initialize {
    /* initializing libxslt global stuff */
    exsltRegisterAll();
    exslt_org_regular_expressions_init();
    xmlSubstituteEntitiesDefault(1);
    xmlLoadExtDtdDefaultValue = 1;
}

- (instancetype) initWithXSLTString:(NSString *)xslt baseURL:(NSURL *)baseURL {
    if (self = [super init]) {
        xmlDocPtr stylesheetDoc = xmlReadDoc((const xmlChar *)[xslt cStringUsingEncoding:NSUTF8StringEncoding], [[baseURL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding], NULL, XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_XINCLUDE);
        [self setupStyleSheetFromXMLDoc:stylesheetDoc];
    }
    return self;
}

- (instancetype) initWithXSLTURL:(NSURL *)URL {
    if (self = [super init]) {
        xmlDocPtr stylesheetDoc = xmlReadFile([[URL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding], NULL, XSLT_PARSE_OPTIONS | XML_PARSE_XINCLUDE);
        [self setupStyleSheetFromXMLDoc:stylesheetDoc];
    }
    return self;
}

- (void) setupStyleSheetFromXMLDoc:(xmlDocPtr)styleSheetDoc {
    xmlXIncludeProcess(styleSheetDoc);
    self.stylesheet = xsltParseStylesheetDoc(styleSheetDoc);
}

- (NSData *) transformedDataFromData:(NSData *)data isHTML:(BOOL)isHTML withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    if (!self.stylesheet) {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:1 userInfo:
                  @{NSLocalizedFailureReasonErrorKey : @"Either no stylesheet provided, or failed to parse the one provided"}];
        return nil;
    }
    
    if ([data length]==0) {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:2 userInfo:
                  @{NSLocalizedFailureReasonErrorKey : @"No input HTML provided, or the input is empty"}];
        return nil;
    }
    
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!string) {
        string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    string = [string mutableCopy];
    // unescape all unicode characters (ie \u2605) and XML/HTML entities (ie &#x0024;)
    CFStringTransform((__bridge CFMutableStringRef)string, NULL, kCFStringTransformToXMLHex, YES);
    CFStringTransform((__bridge CFMutableStringRef)string, NULL, CFSTR("Any-Hex/Java"), YES);
    xmlChar *cString = (xmlChar *)[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    xmlParserOption additionalOptions = isHTML ?
        HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING
      : XML_PARSE_RECOVER | XML_PARSE_NOERROR | XML_PARSE_NOWARNING;
    
    xmlDocPtr doc = isHTML ? htmlReadDoc(cString, NULL, NULL, XSLT_PARSE_OPTIONS | additionalOptions)
    : xmlReadDoc(cString, NULL, NULL, XSLT_PARSE_OPTIONS | additionalOptions);

    xsltTransformContextPtr ctxt = xsltNewTransformContext(self.stylesheet, doc);
    if (ctxt == NULL) {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:3 userInfo:
                  @{NSLocalizedFailureReasonErrorKey : @"Unable to create transform context"}];
        return nil;
    }

    xsltSetCtxtParseOptions(ctxt, XSLT_PARSE_OPTIONS | additionalOptions);
    ctxt->xinclude = 1;

    SkyXSLTParams *xsltParams = [[SkyXSLTParams alloc]initWithParams:params];
    /* actual applying stylesheet */
    xmlDocPtr res = xsltApplyStylesheetUser(self.stylesheet, doc, (const char **)xsltParams.paramsBuf, NULL, NULL, ctxt);

    xsltFreeTransformContext(ctxt);
    /* dumping bytes of the result */
    xmlChar *buf;
    int size;

    xsltSaveResultToString(&buf, &size, res, self.stylesheet);

    /* freeing all other stuff */
    xmlFreeDoc(doc);
    xmlFreeDoc(res);

    /* producing result */
    NSData *result = nil;
    if (buf) {
        result = [NSData dataWithBytesNoCopy:buf length:size freeWhenDone:YES];
    }

    return result;
}

- (NSString *) stringFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError *__autoreleasing *)error {
    NSData *data = [self transformedDataFromData:html isHTML:YES withParams:params error:error];
    NSString *result = nil;
    if (data) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id) JSONObjectFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromData:html isHTML:YES withParams:params error:error];
    id JSONObject = nil;
    if (data) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    }
    return JSONObject;
}

- (NSString *) stringFromXMLData:(NSData *)xml withParams:(NSDictionary *) params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromData:xml isHTML:NO withParams:params error:error];
    NSString *result = nil;
    if (data) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id) JSONObjectFromXMLData:(NSData *)xml withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromData:xml isHTML:NO withParams:params error:error];
    id JSONObject = nil;
    if (data) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    }
    return JSONObject;

}

@end
