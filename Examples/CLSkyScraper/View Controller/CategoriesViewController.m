//
//  CategoriesViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/25/14.
//
//

#import "Macros.h"
#import "CategoriesViewController.h"
#import <SkyScraper/SkyScraper.h>
#import <SkyScraper/SkyScraper+AFNetworking.h>
#import <SkyScraper/SkyScraper+Mantle.h>

#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD.h>
#import "SubcategoriesViewController.h"

@interface CategoriesViewController ()
@property (nonatomic,strong) NSDictionary *categoriesTree;
@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    self.title = self.site[@"name"];
    [self loadData];
}

- (void) loadData {
    NSURL *siteURL = [NSURL URLWithString:self.site[@"link"]];
    NSString *baseURL = [[siteURL.scheme stringByAppendingString:@"://"] stringByAppendingString:siteURL.host];
    NSURLRequest *request = [NSURLRequest requestWithURL:siteURL];
    NSURL *adsearchXSLURL = [[NSBundle mainBundle] URLForResource:@"categories" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:adsearchXSLURL];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"URL":QUOTED(RSLASH(self.site[@"link"])),@"baseURL":QUOTED(baseURL)} modelAdapter:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.categoriesTree = responseObject;
        [weakSelf redisplayData];
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Loading categories..."];
    [operation start];
}

- (void) redisplayData {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoriesTree[@"categories"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    cell.textLabel.text = self.categoriesTree[@"categories"][indexPath.row][@"name"];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SubcategoriesViewController *controller = segue.destinationViewController;
    controller.category = self.categoriesTree[@"categories"][[self.tableView indexPathForSelectedRow].row];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
