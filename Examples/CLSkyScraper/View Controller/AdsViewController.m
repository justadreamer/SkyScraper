//
//  AdsViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/25/14.
//
//
#import "Macros.h"

#import "AdsViewController.h"
#import <SkyScraper/SkyScraper.h>
#import <SkyScraper/SkyScraper+AFNetworking.h>
#import <SkyScraper/SkyScraper+Mantle.h>

#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

#import "AdDataContainer.h"
#import "AdData.h"
#import "AdCell.h"
#import "AdDetailViewController.h"

@interface AdsViewController ()
@property (nonatomic,strong) AdDataContainer *container;
@end

@implementation AdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*debug:
    self.subcategory = @{
     @"link" : @"http://bakersfield.craigslist.org/search/ata",
     @"name" : @"antiques"
    };
 */
    self.title = self.subcategory[@"name"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 82.0;
    [self loadData];
}

- (void) loadData {
    NSURL *URL = [NSURL URLWithString:self.subcategory[@"link"]];
    NSString *baseURL = [[URL.scheme stringByAppendingString:@"://"] stringByAppendingString:URL.host];

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURL *adsearchXSLURL = [[NSBundle mainBundle] URLForResource:@"adsearch" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:adsearchXSLURL];
    SkyMantleModelAdapter *modelAdapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[AdDataContainer class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"URL":QUOTED(RSLASH(self.subcategory[@"link"])),@"baseURL":QUOTED(baseURL)} modelAdapter:modelAdapter];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    manager.responseSerializer = serializer;
    __typeof(self) __weak weakSelf = self;
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",responseObject);
        weakSelf.container = responseObject;
        [weakSelf redisplayData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
}

- (void) redisplayData {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.container.ads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AdCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdCell" forIndexPath:indexPath];
    AdData *adData = self.container.ads[indexPath.row];
    cell.adData = adData;

    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
    [cell layoutIfNeeded];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AdDetailViewController *detailViewController = (AdDetailViewController *)segue.destinationViewController;
    AdData *adData = self.container.ads[[self.tableView indexPathForSelectedRow].row];
    detailViewController.adURL = adData.URL;
}

@end
