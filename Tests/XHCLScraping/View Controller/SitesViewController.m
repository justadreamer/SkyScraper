//
//  SitesViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/24/14.
//
//

#import "SitesViewController.h"
#import "AdsViewController.h"

@interface SitesViewController ()

@end

@implementation SitesViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SiteCell" forIndexPath:indexPath];
    cell.textLabel.text = self.sites[indexPath.row][@"name"];
    cell.detailTextLabel.text = self.sites[indexPath.row][@"link"];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AdsViewController *adsVC = segue.destinationViewController;
    NSDictionary *site = self.sites[[self.tableView indexPathForSelectedRow].row];
    adsVC.site = site;
}


@end
