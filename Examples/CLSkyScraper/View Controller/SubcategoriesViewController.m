//
//  SubcategoriesViewController.m
//  Tests
//
//  Created by Eugene Dorfman on 10/26/14.
//
//

#import "SubcategoriesViewController.h"
#import "AdsViewController.h"
@interface SubcategoriesViewController ()

@end

@implementation SubcategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.category[@"name"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.category[@"subcategories"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubcategoryCell" forIndexPath:indexPath];
    cell.textLabel.text = self.category[@"subcategories"][indexPath.row][@"name"];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AdsViewController *controller = segue.destinationViewController;
    controller.subcategory = self.category[@"subcategories"][[self.tableView indexPathForSelectedRow].row];
}

@end
