//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductWebViewController.h"

@interface ProductViewController ()

@property (nonatomic, retain) NSMutableArray *appleProducts;
@property (nonatomic, retain) NSMutableArray *samsungProducts;
@property (nonatomic, retain) NSMutableArray *htcProducts;
@property (nonatomic, retain) NSMutableArray *blackberryProducts;


@end

@implementation ProductViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.products = [[NSMutableArray alloc] init];
    
    if ([self.title isEqualToString:@"Apple mobile devices"]) {
        // Make sure product is still deleted after leaving view
        if (!self.appleProducts) {
            self.appleProducts = [[NSMutableArray alloc] initWithObjects:@"iPad", @"iPod Touch",@"iPhone", nil];
        }
        self.products = self.appleProducts;
    } else if ([self.title isEqualToString:@"Samsung mobile devices"]) {
        if (!self.samsungProducts) {
            self.samsungProducts = [[NSMutableArray alloc] initWithObjects:@"Galaxy S4", @"Galaxy Note", @"Galaxy Tab", nil];
        }
        self.products = self.samsungProducts;
    } else if ([self.title isEqualToString:@"HTC mobile devices"]) {
        if (!self.htcProducts) {
            self.htcProducts = [[NSMutableArray alloc] initWithObjects:@"HTC One",@"HTC Nexus",@"HTC Desire", nil];
        }
        self.products = self.htcProducts;
    } else if ([self.title isEqualToString:@"Blackberry mobile devices"]) {
        if (!self.blackberryProducts) {
            self.blackberryProducts = [[NSMutableArray alloc] initWithObjects: @"Blackberry Classic",@"Blackberry Passport",@"Blackberry Priv", nil];
        }
        self.products = self.blackberryProducts;
    }
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.products count];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [self.products objectAtIndex:[indexPath row]];
    cell.imageView.image = self.logo;
    return cell;
}


// Override to support conditional editing of the table view.
// Deleting products and companies - return YES
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
// Deleting products and companies
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.products removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *productRow = [[self.products objectAtIndex:fromIndexPath.row] retain];
    [self.products removeObject:productRow];
    [self.products insertObject:productRow atIndex:toIndexPath.row];
    [productRow release];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pass the selected object to the new view controller. Can access properties of ProductWebViewController by adding ".urlname"
    ProductWebViewController *webViewController = [[ProductWebViewController alloc] initWithNibName:@"ProductWebViewController" bundle:nil];

    if ([self.title  isEqual: @"Apple mobile devices"]) {
        if (indexPath.row == 0){
            webViewController.productURL = [NSURL URLWithString:@"http://www.apple.com/ipad/"];
        } else if (indexPath.row == 1){
            webViewController.productURL = [NSURL URLWithString:@"http://www.apple.com/ipod/"];
        } else if (indexPath.row == 2){
            webViewController.productURL = [NSURL URLWithString:@"http://www.apple.com/iphone/"];
        }
    }
    
    if ([self.title  isEqual: @"Samsung mobile devices"]) {
        if (indexPath.row == 0){
            webViewController.productURL = [NSURL URLWithString:@"http://www.samsung.com/global/galaxy/"];
        } else if (indexPath.row == 1){
            webViewController.productURL = [NSURL URLWithString:@"http://www.samsung.com/global/galaxy/galaxy-note5/"];
        } else if (indexPath.row == 2){
            webViewController.productURL = [NSURL URLWithString:@"http://www.samsung.com/us/mobile/galaxy-tab/"];
        }
    }
    
    if ([self.title  isEqual: @"HTC mobile devices"]) {
        if (indexPath.row == 0){
            webViewController.productURL = [NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-one-m8/"];
        } else if (indexPath.row == 1){
            webViewController.productURL = [NSURL URLWithString:@"http://www.htc.com/us/tablets/nexus-9/"];
        } else if (indexPath.row == 2){
            webViewController.productURL = [NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-desire-626/"];
        }
    }
    
    if ([self.title  isEqual: @"Blackberry mobile devices"]) {
        if (indexPath.row == 0){
            webViewController.productURL = [NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-classic/overview.html"];
        } else if (indexPath.row == 1){
            webViewController.productURL = [NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-passport/overview.html"];
        } else if (indexPath.row == 2){
            webViewController.productURL = [NSURL URLWithString:@"http://us.blackberry.com/smartphones/priv-by-blackberry/overview.html"];
        }
    }
    
    // Push the view controller.
    [self.navigationController pushViewController:webViewController animated:YES];
    
}
 


@end
