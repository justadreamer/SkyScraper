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
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libexslt/exslt.h>

#import "XHProcessor.h"

extern int xmlLoadExtDtdDefaultValue;

@interface XHProcessor()
@property (nonatomic,strong) NSString *xslt;
@property (nonatomic,assign) xsltStylesheetPtr stylesheet;
@property (nonatomic,assign) char **paramsBuf;
@property (nonatomic,assign) int nParams;
@end

@implementation XHProcessor
- (void) dealloc {
    xsltFreeStylesheet(self.stylesheet);
    [self freeParams];
}

+ (void)initialize {
    /* initializing libxslt global stuff */
    exsltRegisterAll();
    xmlSubstituteEntitiesDefault(1);
    xmlLoadExtDtdDefaultValue = 1;
}

- (void) freeParams {
    for (int i=0;i<self.nParams;++i) {
        if (self.paramsBuf[i]) {
            free(self.paramsBuf[i]);
        }
    }
    if (self.paramsBuf) {
        free(self.paramsBuf);
    }
}

- (void) setParams:(NSDictionary *)params {
    [self freeParams];
    _params = params;
    self.nParams = 2 * (int) [_params count];
    self.paramsBuf = calloc(self.nParams+1, sizeof(char *));
    
    __block int i = 0;
    [_params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *skey = [NSString stringWithFormat:@"%@",key];
        NSString *sval = [NSString stringWithFormat:@"%@",obj];
        char *keybuf = calloc(2*[skey length]+1, sizeof(char));
        char *valbuf = calloc(2*[sval length]+1, sizeof(char));
        if ([skey getCString:keybuf maxLength:2*[skey length] encoding:NSUTF8StringEncoding] &&
            [sval getCString:valbuf maxLength:2*[sval length] encoding:NSUTF8StringEncoding]) {
            self.paramsBuf[i++]=keybuf;
            self.paramsBuf[i++]=valbuf;
        }
    }];
    self.paramsBuf[i]=NULL;
}

- (instancetype) initWithXSLT:(NSString *)xslt {
    if (self = [super init]) {
        self.stylesheet = NULL;
        self.xslt = xslt;
    }
    return self;
}

- (NSString *) processHTML:(NSString *)html {
    if (!html) {
        return nil;
    }
    if (!self.stylesheet) {
        [self compile];
    }

    htmlDocPtr doc = htmlParseDoc((xmlChar *)[html cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    htmlDocPtr res = xsltApplyStylesheet(self.stylesheet, doc, (const char **)self.paramsBuf);
    xmlChar *buf;
    int size;
    htmlDocDumpMemory(res, &buf, &size);
    
    xmlFreeDoc(doc);
    xmlFreeDoc(res);
    
    NSString *result = nil;
    if (buf) {
        result = [[NSString alloc] initWithUTF8String:(const char *)buf];
        xmlFree(buf);
    }
    return result;
}

- (void) compile {
    xmlDocPtr stylesheetDoc = xmlReadDoc((const xmlChar *)[self.xslt cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, XML_PARSE_RECOVER | XML_PARSE_NOENT);
    self.stylesheet = xsltParseStylesheetDoc(stylesheetDoc);
}
@end
