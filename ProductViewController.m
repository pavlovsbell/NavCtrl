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

@property (nonatomic, retain) NSIndexPath *indexPathProperty;

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Button to add a product
    UIBarButtonItem *addProductButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct)];
    
    // Two buttons on the right side
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, addProductButton, nil];
    self.navigationController.toolbarHidden = YES;
    
}

- (void)addProduct {
    
    NSLog(@"add");
    
    // Create new alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a product" message:@"Add product name and URL" preferredStyle:UIAlertControllerStyleAlert];
    
    // Alert text fields
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *addProductNameText){
        addProductNameText.placeholder = @"Product Name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *addProductURLText){
        addProductURLText.placeholder = @"URL";
    }];
    
    // Alert buttons
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }];
    UIAlertAction *addProductAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *addProduct){
        
        // Turn URL string into URL
        NSURL *url = [[NSURL alloc] initWithString:alertController.textFields[1].text];
        
        // Adding a new product; create new product with name and URL
        ProductClass *newProduct = [[ProductClass alloc] initWithProductName:alertController.textFields[0].text andProductURL:url];
        
        [self.currentCompany.companyProducts addObject:newProduct];
        [self.tableView reloadData];
    }];
    
    [alertController addAction:addProductAction];
    [alertController addAction:cancel];
    
    // Make alert pop up when button pressed
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    return [self.currentCompany.companyProducts count];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Each cell displays company logo and product name
    cell.textLabel.text = [[self.currentCompany.companyProducts objectAtIndex:[indexPath row]] productName];
    cell.imageView.image = self.currentCompany.companyLogo;
    
    // Long press gesture to edit products
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFrom:)];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
 
    return cell;
}


- (void)handleLongPressFrom:(UIGestureRecognizer*)longPressRecognizer {
    NSLog(@"Pressed successfully");
    
    // Create new alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit product" message:@"Feel free to change the name and URL" preferredStyle:UIAlertControllerStyleAlert];
    
    // Alert text fields
    
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *productNameText){
        productNameText.text = [[self.currentCompany.companyProducts objectAtIndex:currentIndexPath.row] productName];
        productNameText.placeholder = @"Product Name";
    }];
    
    NSString *urlString = [[[self.currentCompany.companyProducts objectAtIndex:currentIndexPath.row] productURL] absoluteString];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *productURLText){
        productURLText.text = urlString;
        productURLText.placeholder = @"URL";
    }];

    // Alert buttons
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }];
    UIAlertAction *saveProductDetails = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *saveProductDetails){
        [self.currentCompany.companyProducts objectAtIndex:currentIndexPath.row].productName = alertController.textFields[0].text;
        
        // Turn URL string into URL
        NSURL *url = [[NSURL alloc] initWithString:alertController.textFields[1].text];
        [self.currentCompany.companyProducts objectAtIndex:currentIndexPath.row].productURL = url;
        [self.tableView reloadData];
     }];
        
        [alertController addAction:saveProductDetails];
        [alertController addAction:cancel];
        
        // Make alert pop up when button pressed
        [self presentViewController:alertController animated:YES completion:nil];
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
        [self.currentCompany.companyProducts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *productRow = [[self.currentCompany.companyProducts objectAtIndex:fromIndexPath.row] retain];
    [self.currentCompany.companyProducts removeObject:productRow];
    [self.currentCompany.companyProducts insertObject:productRow atIndex:toIndexPath.row];
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
    webViewController.productURLRequest = [[self.currentCompany.companyProducts objectAtIndex:indexPath.row] productURL];
    
    // Push the view controller.
    [self.navigationController pushViewController:webViewController animated:YES];
    
}
 


@end
