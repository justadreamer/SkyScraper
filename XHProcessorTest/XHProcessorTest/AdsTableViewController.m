//
//  AdsTableViewController.m
//  XHProcessorTest
//
//  Created by Eugene Dorfman on 10/3/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//
#import <SVProgressHUD.h>
#import "AdsTableViewController.h"
#import "XHTransformation.h"
#import "AdDataContainer.h"
#import "AdTableViewCell.h"

@interface AdsTableViewController ()
@property (nonatomic,strong) AdDataContainer *container;
@end

@implementation AdsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.container.ads.count;
}


- (void) loadData {
    [SVProgressHUD show];
    __typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        
        NSString *adsearchXSLTPath = [[NSBundle mainBundle] pathForResource:@"adsearch" ofType:@"xsl"];
        NSString *adsearchHTMLPath = [[NSBundle mainBundle] pathForResource:@"sss" ofType:@"html"];
        
        NSError *error = nil;
        NSString *adsearchXSLT = [NSString stringWithContentsOfFile:adsearchXSLTPath encoding:NSUTF8StringEncoding error:&error];
        NSString *adsearchHTML = [NSString stringWithContentsOfFile:adsearchHTMLPath encoding:NSUTF8StringEncoding error:&error];
        
        XHTransformation *processor = [[XHTransformation alloc] initWithXSLTString:adsearchXSLT baseURL:nil];
        NSDictionary *params = @{@"CLURL":@"'http://losangeles.craigslist.org/sss'"};

        error = nil;
        NSDictionary *JSON = [processor transformedJSONObjectFromHTML:adsearchHTML withParams:params error:&error];
        
        if (error) {
            NSLog(@"error deserializing JSON string: %@",error);
        }
        
        error = nil;
        weakSelf.container = [MTLJSONAdapter modelOfClass:AdDataContainer.class fromJSONDictionary:JSON error:&error];
        if (error) {
            NSLog(@"failed deserializing JSON dictionary into model: %@",error);
        }
        
        NSLog(@"AdDataContainer: %@",weakSelf.container);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [SVProgressHUD dismiss];
        });
    });
}

- (AdData *) adDataForIndexPath:(NSIndexPath *)indexPath {
    return self.container.ads[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdTableViewCell" forIndexPath:indexPath];
    cell.adData = [self adDataForIndexPath:indexPath];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
