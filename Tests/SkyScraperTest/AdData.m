//
//  AdData.m
//  CLSkyScraper
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AdData.h"

@implementation AdData
+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"postingID":@"postingID",
             @"title":@"title",
             @"URL":@"link",
             @"thumbnailURL":@"thumbnail",
             @"date":@"date",
             @"price":@"price",
             @"location":@"location",
             
             @"htmlBody":@"html_body",
             @"textBody":@"text_body",
             @"posted":@"posted",
             @"updated":@"updated",
             @"imageURLs":@"image_urls"
             };
}

+ (NSValueTransformer *) URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *) thumbnailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *) imageURLsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^NSArray *(NSArray *imageURLStrings, BOOL *success, NSError **error) {
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *s in imageURLStrings) {
            [imageURLs addObject:[NSURL URLWithString:s]];
        }
        return imageURLs;
    }];
}

@end
