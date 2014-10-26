//
//  StatesViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/24/14.
//
//

#import "StatesViewController.h"
#import "SitesViewController.h"
@interface StatesViewController ()

@end

@implementation StatesViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.states.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StateCell"  forIndexPath:indexPath];
    cell.textLabel.text = self.states[indexPath.row][@"name"];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SitesViewController *sitesVC = segue.destinationViewController;
    NSDictionary *state = self.states[[self.tableView indexPathForSelectedRow].row];
    sitesVC.sites = state[@"sites"];
    sitesVC.title = state[@"name"];
}

@end
