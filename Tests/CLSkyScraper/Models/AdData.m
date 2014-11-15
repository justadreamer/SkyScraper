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
             @"location":@"location",
             
             @"htmlBody":@"html_body",
             @"textBody":@"text_body",
             @"posted":@"posted",
             @"updated":@"updated",
             @"imageURLs":@"image_urls"
             };
}

+ (NSValueTransformer *) URLJSONTransformer {
    return [URLTransformer transformer];
}

+ (NSValueTransformer *) thumbnailURLJSONTransformer {
    return [URLTransformer transformer];
}

+ (NSValueTransformer *) imageURLsJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^NSArray *(NSArray *imageURLStrings) {
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *s in imageURLStrings) {
            [imageURLs addObject:[NSURL URLWithString:s]];
        }
        return imageURLs;
    }];
}

@end
