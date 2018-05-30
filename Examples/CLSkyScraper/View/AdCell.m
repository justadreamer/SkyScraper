//
//  AdViewTableViewCell.m
//  Tests
//
//  Created by Eugene Dorfman on 10/29/14.
//
//

#import "AdCell.h"
#import "AdData.h"
#import <AFNetworking/AFNetworking.h>
#import "UIKit+AFNetworking.h"

#import <SkyScraper/SkyScraper.h>
#import <SkyScraper/SkyScraper+AFNetworking.h>
#import <SkyScraper/SkyScraper+Mantle.h>

@interface AdCell ()
@property (nonatomic,strong) IBOutlet UILabel *title;
@property (nonatomic,strong) IBOutlet UILabel *subtitle;
@property (nonatomic,strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@property (nonatomic,strong) NSURLSessionDataTask *task;
@end

@implementation AdCell

- (void) dealloc {
    [self.task cancel];
}

- (void) setAdData:(AdData *)adData {
    _adData = adData;
    
    // this is called here just for testing multithreading - i.e. simulatenous usage of the same XSLTransformation
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
    [self.task cancel];

    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:[self.class detailTransformation] params:nil modelAdapter:nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    manager.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    self.task = [manager GET:self.adData.URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject=%@",responseObject);
        [weakSelf showData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

    self.title.text = nil;
    self.subtitle.text = nil;
    self.thumbnail.image = nil;

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
