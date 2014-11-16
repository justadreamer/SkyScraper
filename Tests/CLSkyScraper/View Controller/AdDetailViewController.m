//
//  AdDetailViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/30/14.
//
//

#import "AdDetailViewController.h"
#import "Macros.h"
#import <SkyScraper/SkyScraper.h>
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "AdData.h"
#import "SVProgressHUD.h"

@interface AdDetailViewController ()
@property (nonatomic,strong) AdData *adData;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *descrLabel;
@property (nonatomic,strong) IBOutlet UIScrollView *imagesScrollView;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *imagesScrollViewHeight;
@property (nonatomic,strong) IBOutlet UILabel *postingIDLabel;
@property (nonatomic,strong) IBOutlet UILabel *postedLabel;
@property (nonatomic,strong) IBOutlet UILabel *updatedLabel;
@property (nonatomic,strong) IBOutlet UIButton *openInSafariButton;
@end

@implementation AdDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagesScrollViewHeight.constant = 0;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.adURL];
    NSURL *adsearchXSLURL = [[NSBundle mainBundle] URLForResource:@"addetail" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:adsearchXSLURL];
    SkyMantleModelAdapter *modelAdapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[AdData class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:nil modelAdapter:modelAdapter];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.adData = responseObject;
        weakSelf.adData.URL = weakSelf.adURL;
        NSLog(@"%@",weakSelf.adData);
        [weakSelf redisplayData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    [operation start];
}

- (void) redisplayData {
    self.titleLabel.text = self.adData.title;
    self.descrLabel.text = self.adData.textBody;
    self.postingIDLabel.text = [NSString stringWithFormat:@"post id: %@",self.adData.postingID];
    self.postedLabel.text = [NSString stringWithFormat:@"posted: %@",self.adData.posted];
    self.updatedLabel.text = [NSString stringWithFormat:@"updated: %@", self.adData.updated];
    self.openInSafariButton.hidden = NO;
    [self addImages];
}

- (void) addImages {
    if (self.adData.imageURLs.count) {
        self.imagesScrollViewHeight.constant = 320;
        NSMutableString *horFormat = [NSMutableString stringWithString:@"H:|"];
        NSMutableArray *verConstraints = [NSMutableArray array];
        NSMutableDictionary *viewsDict = [NSMutableDictionary dictionaryWithDictionary:@{@"topView":self.view}];
        [self.adData.imageURLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [imageView setImageWithURL:URL];
            [self.imagesScrollView addSubview:imageView];
            NSString *viewName = [NSString stringWithFormat:@"imageView%lu",(unsigned long)idx];
            [horFormat appendString:[NSString stringWithFormat:@"-0-[%@(==topView)]",viewName]];
            [viewsDict addEntriesFromDictionary:@{viewName:imageView}];


            NSString *verFormat = [NSString stringWithFormat:@"V:|-0-[%@(==scrollView)]-0-|",viewName];
            NSArray *ver = [NSLayoutConstraint constraintsWithVisualFormat:verFormat options:NSLayoutFormatAlignAllBaseline metrics:nil views:@{viewName:imageView,@"scrollView":self.imagesScrollView}];
            [verConstraints addObjectsFromArray:ver];
        }];
        
        [horFormat appendString:@"-0-|"];
        NSArray *horConstraints = [NSLayoutConstraint constraintsWithVisualFormat:horFormat options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewsDict];
        [self.view addConstraints:horConstraints];
        [self.view addConstraints:verConstraints];
    }
}

- (IBAction) openInSafari:(id)sender {
    [[UIApplication sharedApplication] openURL:self.adURL];
}

@end
