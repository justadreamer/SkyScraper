//
//  AdData.h
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface AdData : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *postingID;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSURL *URL;
@property (nonatomic,strong) NSURL *thumbnailURL;
@property (nonatomic,strong) NSString *date;

@property (nonatomic,strong) NSString *posted;
@property (nonatomic,strong) NSString *updated;
@property (nonatomic,strong) NSString *htmlBody;
@property (nonatomic,strong) NSString *textBody;
@property (nonatomic,strong) NSArray *imageURLs;

@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *location;
@end
