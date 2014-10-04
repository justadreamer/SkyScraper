//
//  XHProcessor.h
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHTransformation : NSObject

- (instancetype) init NS_UNAVAILABLE;

/**
 *  Designated initializer
 *
 *  @param xslt string representation of an XSLT stylesheet in UTF8 encoding
 *  @param baseURL an URL that is used primarily for resolving an XInclude pointing at relative location
 *
 *  @return instance of XHTransformation
 */
- (instancetype) initWithXSLTString:(NSString *)xslt baseURL:(NSURL *)baseURL;


/**
 *  Designated initializer
 *
 *  @param path to load an XSLT stylesheet from in UTF8 encoding
 *
 *  @return instance of XHTransformation
 */
- (instancetype) initWithXSLTFilePath:(NSString *)path;

/**
 *  The actual transformation of the HTML document happens here.
 *
 *  @param html a string representation of a HTML document in UTF8 encoding
 *  @param params a dictionary of params to be passed when the stylesheet transformation is applied
 * beware that when you pass a string param, you should enclose the actual string value into single quotes
 * otherwise it will be treated as an XPath within the XSLT
 *  @param error out param which contains an NSError object if anything failed during transformation
 *
 *  @return a string representation of the transformed HTML document in UTF8 encoding
 */
- (NSString *) transformedStringFromHTML:(NSString *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error;

/**
 *  A convenience method that internally uses transformedStringFromHTML:withParams: and should be used
 * in case you know that XSLT transform will produce JSON from an HTML document
 *
 *  @param html   a string representation of a HTML document in UTF8 encoding
 *  @param params a dictionary of params to be passed when the stylesheet transformation is applied
 *  @param error an out param which contains an NSError object if anything failed during transformation
 *
 *  @return either NSDictionary or NSArray object corresponding to the string JSON representation
 */
- (id) transformedJSONObjectFromHTML:(NSString *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error;

@end
