//
//  AdDataContainer.m
//  CLSkyScraper
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AdDataContainer.h"
#import "AdData.h"

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
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}
@end
