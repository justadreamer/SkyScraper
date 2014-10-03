//
//  XHProcessor.h
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHProcessor : NSObject
/**
 *  The parameters dictionary can be set either once or every time before calling processHTML
 */
@property (nonatomic,strong) NSDictionary *params;

- (instancetype) init NS_UNAVAILABLE;

/**
 *  Designated initializer
 *
 *  @param xslt a string representation of an XSLT stylesheet in UTF8 encoding
 *
 *  @return instance of XHProcessor
 */
- (instancetype) initWithXSLT:(NSString *)xslt;

/**
 *  The actual transformation of the HTML happens here.
 *
 *  @param html a string representation of a HTML document in UTF8 encoding
 *
 *  @return a string representation of the transformed HTML document in UTF8 encoding
 */
- (NSString *) processHTML:(NSString *)html;

@end
