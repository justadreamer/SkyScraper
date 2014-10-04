//
//  XHProcessor.m
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#include <string.h>
#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLparser.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/DOCBparser.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include "libxslt/xslt.h"
#include "libxslt/xsltInternals.h"
#include "libxslt/transform.h"
#include "libxslt/xsltutils.h"
#include "libexslt/exslt.h"

#import "XHTransformation.h"

extern int xmlLoadExtDtdDefaultValue;

@interface XHTransformation()
@property (nonatomic,assign) xsltStylesheetPtr stylesheet;
@end

@implementation XHTransformation
- (void) dealloc {
    xsltFreeStylesheet(self.stylesheet);
}

+ (void)initialize {
    /* initializing libxslt global stuff */
    exsltRegisterAll();
    xmlSubstituteEntitiesDefault(1);
    xmlLoadExtDtdDefaultValue = 1;
}

- (instancetype) initWithXSLTString:(NSString *)xslt baseURL:(NSURL *)baseURL {
    if (self = [super init]) {
        xmlDocPtr stylesheetDoc = xmlReadDoc((const xmlChar *)[xslt cStringUsingEncoding:NSUTF8StringEncoding], [[baseURL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding], NULL, XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_XINCLUDE);
        self.stylesheet = xsltParseStylesheetDoc(stylesheetDoc);
    }
    return self;
}

- (instancetype) initWithXSLTPath:(NSString *)path {
    if (self = [super init]) {
        self.stylesheet = xsltParseStylesheetFile((xmlChar *)[path cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return self;
}

- (NSData *) transformedDataFromHTML:(NSString *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    if (!html) {
        return nil;
    }
    
    /* parameters */
    int nParams = 2 * (int) [params count];
    char * *paramsBuf = calloc(nParams+1, sizeof(char *));
    
    __block int i = 0;
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *skey = [NSString stringWithFormat:@"%@",key];
        NSString *sval = [NSString stringWithFormat:@"%@",obj];
        char *keybuf = calloc(2*[skey length]+1, sizeof(char));
        char *valbuf = calloc(2*[sval length]+1, sizeof(char));
        if ([skey getCString:keybuf maxLength:2*[skey length] encoding:NSUTF8StringEncoding] &&
            [sval getCString:valbuf maxLength:2*[sval length] encoding:NSUTF8StringEncoding]) {
            paramsBuf[i++]=keybuf;
            paramsBuf[i++]=valbuf;
        }
    }];
    paramsBuf[i]=NULL;
    

    /* actual applying stylesheet */
    htmlDocPtr doc = htmlParseDoc((xmlChar *)[html cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    htmlDocPtr res = xsltApplyStylesheet(self.stylesheet, doc, (const char **)paramsBuf);
    
    /* dumping bytes of the result */
    xmlChar *buf;
    int size;
    
    htmlDocDumpMemory(res, &buf, &size);
    
    /* freeing parameters */
    for (int i=0;i<nParams;++i) {
        if (paramsBuf[i]) {
            free(paramsBuf[i]);
        }
    }
    if (paramsBuf) {
        free(paramsBuf);
    }

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

- (NSString *) transformedStringFromHTML:(NSString *)html withParams:(NSDictionary *)params error:(NSError *__autoreleasing *)error {
    NSData *data = [self transformedDataFromHTML:html withParams:params error:error];
    NSString *result = nil;
    if (data) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id) transformedJSONObjectFromHTML:(NSString *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromHTML:html withParams:params error:error];
    id JSONObject = nil;
    if (data) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    }
    return JSONObject;
}

@end
