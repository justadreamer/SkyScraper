//
//  LocationViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/24/14.
//
//

#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <XHTransformation/XHTransformation.h>
#import <XHTransformation/XHTransformationHTMLResponseSerializer.h>

#import "ContinentsViewController.h"
#import "StatesViewController.h"


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
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:URLlocationsXSL];
    XHTransformationHTMLResponseSerializer *serializer = [XHTransformationHTMLResponseSerializer serializerWithXHTransformation:transformation params:nil modelAdapter:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:CLURLAboutSites]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.locationsTree = responseObject;
        [weakSelf redisplayData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Loading locations..."];
    [operation start];
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
