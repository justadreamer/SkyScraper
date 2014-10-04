//
//  AdDataContainer.m
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AdDataContainer.h"
#import "AdData.h"
#import "URLTransformer.h"

@implementation AdDataContainer
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title" : @"title",
             @"URLNext" : @"linkNext",
             @"ads" : @"ads"
             };
}

+ (NSValueTransformer *)adsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:AdData.class];
}

+ (NSValueTransformer *)URLNextJSONTransformer {
    return [URLTransformer transformer];
}
@end
