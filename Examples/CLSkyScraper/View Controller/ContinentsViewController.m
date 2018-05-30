//
//  LocationViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/24/14.
//
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <SkyScraper/SkyScraper.h>
#import <SkyScraper/SkyScraper+AFNetworking.h>
#import <SkyScraper/SkyScraper+Mantle.h>

#import <AFNetworking/AFNetworking.h>

#import "ContinentsViewController.h"
#import "StatesViewController.h"
#import "Macros.h"

NSString * const CLURLAboutSites = @"http://www.craigslist.org/about/sites";

@interface ContinentsViewController ()
@property (nonatomic,strong) NSDictionary *locationsTree;
@end

@implementation ContinentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    [self loadData];
}

- (void) loadData {
    NSURL *URLlocationsXSL = [[NSBundle mainBundle] URLForResource:@"locations" withExtension:@"xsl"];
    NSURL *URL = [NSURL URLWithString:CLURLAboutSites];
    NSString *baseURL = [[URL.scheme stringByAppendingString:@"://"] stringByAppendingString:URL.host];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:URLlocationsXSL];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"URL":QUOTED(RSLASH(URL.absoluteString)),@"baseURL":QUOTED(baseURL)} modelAdapter:nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    manager.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.locationsTree = responseObject;
        NSLog(@"locationstree=%@",responseObject);
        [weakSelf redisplayData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Loading locations..."];
}

- (void) redisplayData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.locationsTree[@"continents"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"StateCell"];
    cell.textLabel.text = self.locationsTree[@"continents"][indexPath.row][@"name"];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    StatesViewController *statesVC = segue.destinationViewController;
    NSDictionary *continent = self.locationsTree[@"continents"][[self.tableView indexPathForSelectedRow].row];
    statesVC.states = continent[@"states"];
    statesVC.title = continent[@"name"];
}

@end
