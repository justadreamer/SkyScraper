//
//  AdsViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/25/14.
//
//
#import "Macros.h"

#import "AdsViewController.h"
#import <XHTransformation/XHTransformation.h>
#import <XHTransformation/XHMantleModelAdapter.h>
#import <XHTransformation/XHTransformationHTMLResponseSerializer.h>

#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "AdDataContainer.h"
#import "AdData.h"

@interface AdsViewController ()
@property (nonatomic,strong) AdDataContainer *container;
@end

@implementation AdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.site[@"name"];
    NSURL *siteURL = [NSURL URLWithString:self.site[@"link"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:siteURL];
    NSURL *adsearchXSLURL = [[NSBundle mainBundle] URLForResource:@"adsearch" withExtension:@"xsl"];
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:adsearchXSLURL];
    XHMantleModelAdapter *modelAdapter = [[XHMantleModelAdapter alloc] initAdapterWithModelClass:[AdDataContainer class]];
    XHTransformationHTMLResponseSerializer *serializer = [XHTransformationHTMLResponseSerializer serializerWithXHTransformation:transformation params:@{@"CLURL":QUOTED(self.site[@"link"])} modelAdapter:modelAdapter];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",responseObject);
        weakSelf.container = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    [operation start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.container.ads.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdCell" forIndexPath:indexPath];
    AdData *adData = self.container.ads[indexPath.row];
    cell.textLabel.text = adData.title;
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
