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

#import <SkyScraper/SkyScraper.h>
#import <SkyScraper/SkyScraper+AFNetworking.h>
#import <SkyScraper/SkyScraper+Mantle.h>
#import "AFHTTPRequestOperation.h"

@interface AdCell ()
@property (nonatomic,strong) IBOutlet UILabel *title;
@property (nonatomic,strong) IBOutlet UILabel *subtitle;
@property (nonatomic,strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation AdCell
- (void) dealloc {
    [self.operation cancel];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setAdData:(AdData *)adData {
    _adData = adData;
    
//this is called here just for testing multithreading - i.e. simulatenous usage of the same XSLTransformation
    [self loadDetailsForAdData];
}

- (void) showData {
    self.title.text = self.adData.title;
    NSMutableString *subtitle = [NSMutableString string];
    [subtitle appendString:[self.adData.location length] ? self.adData.location : @""];
    if ([subtitle length]) {
        [subtitle appendString:@", "];
    }
    
    [subtitle appendString:[self.adData.date length] ? self.adData.date : @""];
    if ([subtitle length]) {
        [subtitle appendString:@", "];
    }
    
    [subtitle appendString:[self.adData.postingID length] ? [NSString stringWithFormat:@"pid: %@",self.adData.postingID] : @""];
    
    self.subtitle.text = subtitle;
    
    self.thumbnail.image = nil;
    if (!self.adData.thumbnailURL) {
        self.imageWidthConstraint.constant = 0;
    } else {
        self.imageWidthConstraint.constant = 72.0;
        [self.thumbnail setImageWithURL:self.adData.thumbnailURL placeholderImage:nil];
    }
}

- (void) loadDetailsForAdData {
    [self.operation cancel];

    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:[self.class detailTransformation] params:nil modelAdapter:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.adData.URL];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;

    self.title.text = nil;
    self.subtitle.text = nil;
    self.thumbnail.image = nil;

    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject=%@",responseObject);
        [weakSelf showData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];

    [self.operation start];

}

+ (SkyXSLTransformation *) detailTransformation {
    static SkyXSLTransformation *transformation = nil;
    if (!transformation) {
        NSURL *xslURL = [[NSBundle mainBundle] URLForResource:@"addetail" withExtension:@"xsl"];
        transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:xslURL];
    }
    return transformation;
}
@end
