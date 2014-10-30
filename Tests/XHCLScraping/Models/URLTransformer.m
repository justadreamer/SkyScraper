//
//  URLTransformer.m
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "URLTransformer.h"

@implementation URLTransformer
+ (instancetype) transformer {
    return [self reversibleTransformerWithForwardBlock:^NSURL *(NSString *link) {
        return [link length] ? [NSURL URLWithString:link] : nil;
    } reverseBlock:^NSString *(NSURL *URL) {
        return [URL absoluteString];
    }];
}
@end
