//
//  AdData.m
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AdData.h"
#import "URLTransformer.h"

@implementation AdData
+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"postingID":@"postingID",
             @"title":@"title",
             @"URL":@"link",
             @"thumbnailURL":@"thumbnail",
             @"date":@"date",
             @"price":@"price",
             @"location":@"location"
             };
}

+ (NSValueTransformer *) URLJSONTransformer {
    return [URLTransformer transformer];
}

+ (NSValueTransformer *) thumbnailURLJSONTransformer {
    return [URLTransformer transformer];
}

@end
