//
//  AdDataContainer.h
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "AdData.h"

@interface AdDataContainer : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSURL *URLNext;
@property (nonatomic,strong) NSArray *ads;
@end
