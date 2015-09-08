/*
 * regexp.c: Implementation of the EXSLT -- Regular Expressions module
 *
 * References:
 *   http://exslt.org/regexp/index.html
 *
 * See Copyright for the status of this software.
 *
 * Authors:
 *   Joel W. Reed <joelwreed@gmail.com>
 *   Some modification by Kyle Maxwell
 *   Minor fix for UTF8 strings by Eugene Dorfman <eugene.dorfman@gmail.com>
 *
 * TODO:
 * functions:
 *   regexp:match
 *   regexp:replace
 *   regexp:test
 */
#include "regexp.h"
#import <Foundation/Foundation.h>

static BOOL flagSearch(const xmlChar *flagstr, const xmlChar flag) {
    const xmlChar* i = flagstr;
    while (*i != '\0') {
        if (*i == flag) return YES;
        ++i;
    }
    return NO;
}

static BOOL isCaseInsensitive(const xmlChar *flagstr) {
    return flagSearch(flagstr,'i');
}

static BOOL isGlobal(const xmlChar *flagstr) {
    return flagSearch(flagstr,'g');
}

static NSRegularExpression *makeCocoaRegexp(xmlXPathParserContextPtr ctxt, const xmlChar *regexp, const xmlChar *flagstr) {
    //TODO: support flags
    NSError *error = nil;
    NSRegularExpression *cocoaRegexp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithUTF8String:(const char *)regexp] options:(isCaseInsensitive(flagstr) ? NSRegularExpressionCaseInsensitive : 0) error:&error];
    if (!cocoaRegexp) {
        xsltTransformError (xsltXPathGetTransformContext (ctxt), NULL, NULL,
                            "exslt:regexp %s failed to compile with error: %@ ", regexp, error);
        return nil;
    }
    return cocoaRegexp;
}

static NSArray *
exsltRegexpMatches(xmlXPathParserContextPtr ctxt,
                   const xmlChar* haystack, const xmlChar* regexp,
                   xmlChar *flagstr)
{
    NSRegularExpression *cocoaRegexp = makeCocoaRegexp(ctxt, regexp, flagstr);
    if (!cocoaRegexp) {
        return nil;
    }

    NSString *s = [NSString stringWithUTF8String:(const char *)haystack];
    NSArray *matches = nil;
    NSRange range = NSMakeRange(0, s.length);
    if (isGlobal(flagstr)) {
        matches = [cocoaRegexp matchesInString:s options:0 range:range];
    } else {
        NSTextCheckingResult *result = [cocoaRegexp firstMatchInString:s options:0 range:range];
        if (result) {
            matches = @[result];
        }
    }

    NSMutableArray *results = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (NSUInteger n = 0;n < [match numberOfRanges];++n) {
            NSRange range = [match rangeAtIndex:n];
            NSString *sub = [s substringWithRange:range];
            if (sub) {
                [results addObject:sub];
            }
        }
    }

    return results;
}

static BOOL
exsltRegexpTest(xmlXPathParserContextPtr ctxt,
                const xmlChar* haystack, const xmlChar* regexp,
                xmlChar *flagstr) {
    NSRegularExpression *cocoaRegexp = makeCocoaRegexp(ctxt, regexp, flagstr);
    if (!cocoaRegexp) {
        return NO;
    }
    
    NSString *s = [NSString stringWithUTF8String:(const char *)haystack];
    NSTextCheckingResult *result = [cocoaRegexp firstMatchInString:s options:0 range:NSMakeRange(0, s.length)];
    return [result numberOfRanges]>0;
}


static NSString *
exsltRegexpReplace(xmlXPathParserContextPtr ctxt,
                    const xmlChar* haystack, const xmlChar* regexp,
                   xmlChar *flagstr, const xmlChar *replace) {
    NSRegularExpression *cocoaRegexp = makeCocoaRegexp(ctxt, regexp, flagstr);
    if (!cocoaRegexp) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithUTF8String:(const char *)haystack];

    NSRange range = NSMakeRange(0, s.length);
    NSString *template = [NSString stringWithUTF8String:(const char *)replace];
    if (isGlobal(flagstr)) {
        [cocoaRegexp replaceMatchesInString:s options:0 range:range withTemplate:template];
    } else {
        NSTextCheckingResult *result = [cocoaRegexp firstMatchInString:s options:0 range:range];
        if ([result numberOfRanges]>0) {
            NSRange firstRange = [result rangeAtIndex:0];
            [cocoaRegexp replaceMatchesInString:s options:0 range:firstRange withTemplate:template];
        }
    }
    
    return [s copy];
}


/**
 * exsltRegexpMatchFunction:
 * @ns:
 *
 * Returns a node set of string matches
 */

static void
exsltRegexpMatchFunction (xmlXPathParserContextPtr ctxt, int nargs)
{
    xsltTransformContextPtr tctxt;
    xmlNodePtr node;
    xmlDocPtr container;
    xmlXPathObjectPtr ret = NULL;
    xmlChar *haystack, *regexp, *flagstr;

    if ((nargs < 1) || (nargs > 3)) {
        xmlXPathSetArityError(ctxt);
        return;
    }


    if (nargs > 2) {
      flagstr = xmlXPathPopString(ctxt);
      if (xmlXPathCheckError(ctxt) || (flagstr == NULL)) {
          return;
      }
    } else {
     flagstr = xmlStrdup((xmlChar *)"");
    }
    
    regexp = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (regexp == NULL)) {
        xmlFree(flagstr);
        return;
    }

    haystack = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (haystack == NULL)) {
        xmlFree(regexp);
        xmlFree(flagstr);
        return;
    }

    /* Return a result tree fragment */
    tctxt = xsltXPathGetTransformContext(ctxt);
    if (tctxt == NULL) {
      xsltTransformError(xsltXPathGetTransformContext(ctxt), NULL, NULL,
                         "exslt:regexp : internal error tctxt == NULL\n");
      goto fail;
    }

    container = xsltCreateRVT(tctxt);
    if (container != NULL) {
        xsltRegisterTmpRVT(tctxt, container);
        ret = xmlXPathNewNodeSet(NULL);
        if (ret != NULL) {
            ret->boolval = 0;
            
            NSArray *results = exsltRegexpMatches(ctxt, haystack, regexp, flagstr);
            
            for (NSString *result in results) {
                node = xmlNewDocRawNode(container, NULL, (xmlChar *) "match", (xmlChar *) [result cStringUsingEncoding:NSUTF8StringEncoding]);
                xmlAddChild((xmlNodePtr) container, node);
                xmlXPathNodeSetAddUnique(ret->nodesetval, node);
            }
        }
    }

 fail:
    if (flagstr != NULL)
      xmlFree(flagstr);
    if (regexp != NULL)
      xmlFree(regexp);
    if (haystack != NULL)
      xmlFree(haystack);

    if (ret != NULL)
      valuePush(ctxt, ret);
    else
      valuePush(ctxt, xmlXPathNewNodeSet(NULL));
}

/**
 * exsltRegexpReplaceFunction:
 * @ns:     
 *
 * Returns a node set of string matches
 */

static void
exsltRegexpReplaceFunction (xmlXPathParserContextPtr ctxt, int nargs)
{
    xmlChar *haystack, *regexp, *flagstr, *replace;
    xmlChar *result = NULL;

    if ((nargs < 1) || (nargs > 4)) {
        xmlXPathSetArityError(ctxt);
        return;
    }

    replace = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (replace == NULL)) {
        return;
    }

    flagstr = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (flagstr == NULL)) {
        xmlFree(replace);
        return;
    }

    regexp = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (regexp == NULL)) {
        xmlFree(flagstr);
        xmlFree(replace);
        return;
    }

    haystack = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (haystack == NULL)) {
        xmlFree(regexp);
        xmlFree(flagstr);
        xmlFree(replace);
        return;
    }
    NSString *resultString = exsltRegexpReplace(ctxt,haystack,regexp,flagstr,replace);
    if (resultString) {
        result = xmlUTF8Strndup((xmlChar *)[resultString cStringUsingEncoding:NSUTF8StringEncoding],(int)resultString.length);
    } else {
        result = xmlUTF8Strndup((xmlChar *)haystack, xmlUTF8Strlen(haystack));
    }
fail:
    if (replace != NULL)
            xmlFree(replace);
    if (flagstr != NULL)
            xmlFree(flagstr);
    if (regexp != NULL)
            xmlFree(regexp);
    if (haystack != NULL)
            xmlFree(haystack);

    xmlXPathReturnString(ctxt, result);
}

/**
 * exsltRegexpTestFunction:
 * @ns:     
 *
 * returns true if the string given as the first argument 
 * matches the regular expression given as the second argument
 * 
 */

static void
exsltRegexpTestFunction (xmlXPathParserContextPtr ctxt, int nargs)
{
    xmlChar *haystack, *regexp, *flagstr;

    if ((nargs < 1) || (nargs > 3)) {
        xmlXPathSetArityError(ctxt);
        return;
    }

    if(nargs > 2) {
    flagstr = xmlXPathPopString(ctxt);
      if (xmlXPathCheckError(ctxt) || (flagstr == NULL)) {
          return;
      }
    } else {
      flagstr = xmlStrdup((xmlChar *)"");
    }

    regexp = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (regexp == NULL)) {
        xmlFree(flagstr);
        return;
    }

    haystack = xmlXPathPopString(ctxt);
    if (xmlXPathCheckError(ctxt) || (haystack == NULL)) {
        xmlFree(regexp);
        xmlFree(flagstr);
        return;
    }

    BOOL result = exsltRegexpTest(ctxt, haystack, regexp, flagstr);

fail:
    if (flagstr != NULL)
            xmlFree(flagstr);
    if (regexp != NULL)
            xmlFree(regexp);
    if (haystack != NULL)
            xmlFree(haystack);

    xmlXPathReturnBoolean(ctxt, result);
}

/**
 * exsltRegexpRegister:
 *
 * Registers the EXSLT - Regexp module
 */
void
PLUGINPUBFUN exslt_org_regular_expressions_init (void)
{
    xsltRegisterExtModuleFunction ((const xmlChar *) "match",
                                   (const xmlChar *) EXSLT_REGEXP_NAMESPACE,
                                   exsltRegexpMatchFunction);
    xsltRegisterExtModuleFunction ((const xmlChar *) "replace",
                                   (const xmlChar *) EXSLT_REGEXP_NAMESPACE,
                                   exsltRegexpReplaceFunction);
    xsltRegisterExtModuleFunction ((const xmlChar *) "test",
                                   (const xmlChar *) EXSLT_REGEXP_NAMESPACE,
                                   exsltRegexpTestFunction);
}
