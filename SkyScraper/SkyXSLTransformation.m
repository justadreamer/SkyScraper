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
#include "iconv.h"

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
        _xsltURL = URL;
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
    
    NSString *string = [self stringUTF8:data clean:NO];
    if (!string) {
        string = [self stringUTF8:data clean:YES];
    }
    string = [self unescapeXMLEntities:string isHTML:isHTML];
    
    xmlChar *cString = (xmlChar *)[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    xmlParserOption additionalOptions = isHTML ?
    HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING
    : XML_PARSE_RECOVER | XML_PARSE_NOERROR | XML_PARSE_NOWARNING;
    
    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
    const char *enc = CFStringGetCStringPtr(cfencstr, 0);
    
    xmlDocPtr doc = isHTML ? htmlReadDoc(cString, NULL, enc, XSLT_PARSE_OPTIONS | additionalOptions)
    : xmlReadDoc(cString, NULL, enc, XSLT_PARSE_OPTIONS | additionalOptions);
    
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

#pragma mark - Fix response data

- (NSString*) stringUTF8:(NSData*)data clean:(BOOL)clean {
    data = clean ? [self cleanUTF8:data] : data;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *) cleanUTF8:(NSData *)data {
    // this function is from
    // http://stackoverflow.com/questions/3485190/nsstring-initwithdata-returns-null
    //
    //
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // convert to UTF-8 from UTF-8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

- (NSString*) unescapeXMLEntities:(NSString*)string isHTML:(BOOL)isHTML {
    if (!isHTML) {
        // this need to be done to fix the issue with XML entities inside CDATA
        string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
        string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&#(x?[a-f0-9]{4});?" options:NSRegularExpressionCaseInsensitive error:nil];
    NSMutableString* mutString = [NSMutableString new];
    __block NSInteger startPos = 0;
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [mutString appendString:[string substringWithRange:NSMakeRange(startPos, result.range.location - startPos)]];
        NSString* value = [string substringWithRange:[result rangeAtIndex:1]];
        if (![value containsString:@"x"]) {
            value = [NSString stringWithFormat:@"x%lX",(unsigned long)[value integerValue]];
        }
        [mutString appendFormat:@"&#%@;",value];
        startPos = result.range.location + result.range.length;
    }];
    [mutString appendString:[string substringWithRange:NSMakeRange(startPos, string.length-startPos)]];
    
    CFStringTransform((__bridge CFMutableStringRef)mutString, NULL, kCFStringTransformToXMLHex, YES);
    return mutString;
}

@end
