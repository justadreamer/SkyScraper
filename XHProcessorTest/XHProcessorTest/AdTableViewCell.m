//
//  AdTableViewCell.m
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/4/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AdTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface AdTableViewCell ()
@property (nonatomic,strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic,strong) IBOutlet UILabel *title;
@property (nonatomic,strong) IBOutlet UILabel *date;
@property (nonatomic,strong) IBOutlet UILabel *price;
@property (nonatomic,strong) IBOutlet UILabel *location;
@end

@implementation AdTableViewCell

- (void) setAdData:(AdData *)adData {
    _adData = adData;

    self.title.text = adData.title;
    self.date.text = adData.date;
    self.price.text = adData.price;
    self.location.text = adData.location;
    self.thumbnail.image = nil;
    [self.thumbnail setImageWithURL:adData.thumbnailURL];
}
@end
