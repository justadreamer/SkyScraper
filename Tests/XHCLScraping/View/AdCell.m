//
//  AdViewTableViewCell.m
//  Tests
//
//  Created by Eugene Dorfman on 10/29/14.
//
//

#import "AdCell.h"
#import "AdData.h"
#import "UIKit+AFNetworking.h"

@interface AdCell ()
@property (nonatomic,strong) IBOutlet UILabel *title;
@property (nonatomic,strong) IBOutlet UILabel *subtitle;
@property (nonatomic,strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@end

@implementation AdCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setAdData:(AdData *)adData {
    _adData = adData;
    self.title.text = adData.title;
    NSMutableString *subtitle = [NSMutableString string];
    [subtitle appendString:[adData.location length] ? adData.location : @""];
    if ([subtitle length]) {
        [subtitle appendString:@", "];
    }
    
    [subtitle appendString:[adData.date length] ? adData.date : @""];
    if ([subtitle length]) {
        [subtitle appendString:@", "];
    }
    
    [subtitle appendString:[adData.postingID length] ? [NSString stringWithFormat:@"pid: %@",adData.postingID] : @""];

    self.subtitle.text = subtitle;
        
    self.thumbnail.image = nil;
    if (!self.adData.thumbnailURL) {
        self.imageWidthConstraint.constant = 0;
    } else {
        self.imageWidthConstraint.constant = 72.0;
        [self.thumbnail setImageWithURL:self.adData.thumbnailURL placeholderImage:nil];
    }

}
@end
