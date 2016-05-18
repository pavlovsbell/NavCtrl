//
//  CompanyViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "CompanyViewController.h"
#import "ProductViewController.h"
#import "CompanyMO.h"
#import "StockNetworking.h"

@interface CompanyViewController ()

- (void)addCompany;

@end

@implementation CompanyViewController

#pragma mark - App lifecycle delegates

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
    self.title = @"Mobile device makers";
    
    // Add DAO to access all properties
    self.sharedDAO = [DAO sharedDAO];

    UIBarButtonItem *addCompanyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCompany)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, addCompanyButton, nil];
    self.navigationController.toolbarHidden = YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    // Display stock quote for each company
    [super viewWillAppear:animated]; // Calls superclass, best practice
    
    StockNetworking *networking = [[StockNetworking alloc] init];
    networking.companyViewController = self;
    [networking getStockPrices];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - My methods

- (void)addCompany {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a company" message:@"Please add your company name and up to three products" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *companyNameText){
        companyNameText.placeholder = @"Company Name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *product1Text){
        product1Text.placeholder = @"Product 1";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *product2Text){
        product2Text.placeholder = @"Product 2";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *product3Text){
        product3Text.placeholder = @"Product 3";
    }];
    UIAlertAction *cancel = [[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }] autorelease];
    UIAlertAction *addCompanyAction = [[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *addCompany){
        
        // Makes new company with name
        CompanyClass *newCompany = [self addCompanyFromAlertController: alertController.textFields[0].text];
        
        newCompany.companyProducts = [[[NSMutableArray alloc] init] autorelease];
        
        // Iterate through products and add them to new company's product array
        for (int i = 1; i < alertController.textFields.count; i++) {
            if (alertController.textFields[i].text != nil) {
                ProductClass *product = [[ProductClass alloc] init];
                product = [self addProductsFromAlertController:alertController.textFields[i].text toCompany:newCompany];
                [newCompany.companyProducts addObject:product];
            }
        }
        
        //[self.sharedDAO addProductsToCoreData:newCompany.companyProducts forCompany:newCompany];
        
    }] autorelease];
    
    [alertController addAction:addCompanyAction];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (CompanyClass*)addCompanyFromAlertController:(NSString*)name {
    
    // Adding a new company
    
    CompanyClass *newCompany = [[[CompanyClass alloc] init] autorelease];
    
    // Add new company name to company list
    if (name != nil){
    
        newCompany.companyName = name;
        newCompany.companyLogo = @"logoCompany5.jpg";
        
        NSUInteger tempvar = 0;
        for (int i = 0; i < self.sharedDAO.companyList.count; i++) {
            CompanyClass *company = [self.sharedDAO.companyList objectAtIndex:i];
            if (company.companyID > tempvar) {
                tempvar = company.companyID;
            }
        }
        newCompany.companyID = tempvar + 1;
        newCompany.companyIndex = self.sharedDAO.companyList.count;
    
        [self.sharedDAO addCompanyToCoreData:newCompany];
        [self.sharedDAO.companyList addObject:newCompany];
        [self.tableView reloadData];
    }
    
    return newCompany;
}

- (ProductClass*)addProductsFromAlertController:(NSString*)name toCompany:(CompanyClass*)company {
    
    ProductClass *product = [[ProductClass alloc] init];
    product.productName = name;
    product.urlString = [NSString stringWithFormat:@"http://lmgtfy.com/?q=%@", product.productName];
//    NSString *string = [NSString stringWithFormat:product.urlString];
    NSURL *url = [[NSURL alloc] initWithString:product.urlString];
    product.productURL = url;
    product.productIndex = company.companyProducts.count;
    
    
    return product;
    
    [url release];
    [product release];
}

- (void)handleLongPressFrom:(UIGestureRecognizer*)longPressRecognizer {
    NSLog(@"Pressed successfully");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit company" message:@"Edit company name" preferredStyle:UIAlertControllerStyleAlert];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
    
    CompanyClass *currentCompany = [self.sharedDAO.companyList objectAtIndex:[currentIndexPath row]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *companyNameText){
        companyNameText.text = currentCompany.companyName;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *companyStockSymbolText){
        companyStockSymbolText.text = currentCompany.companyStockSymbol;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *companyLogoText){
        companyLogoText.text = @"Choose a number 1-5";
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }];
    UIAlertAction *saveCompanyDetails = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *saveProductDetails){
        
        currentCompany.companyName = alertController.textFields[0].text;
        currentCompany.companyStockSymbol = alertController.textFields[1].text;
        
        // Make sure input is a number
        NSString *testString = alertController.textFields[2].text;
        NSScanner *scanner = [NSScanner scannerWithString:testString];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        
        
        if (isNumeric == YES){
            int logoNumber = [testString intValue];
            //Make sure the number is not less than 1
            if (logoNumber < 1) {
                logoNumber = 1;
            }
            //Make sure the number is not greater than 5
            else if (logoNumber > 5) {
                logoNumber = 5;
            }
            else {
                logoNumber = logoNumber;
            }
            
            currentCompany.companyLogo = [NSString stringWithFormat:@"logoCompany%d.jpg",logoNumber];
            
        }
        else {
            currentCompany.companyLogo = @"logoCompany5.jpg";
        }
        
        [self.sharedDAO saveCompanyChangesToCoreData:currentCompany];
        [self.tableView reloadData];
    }];
    
    [alertController addAction:saveCompanyDetails];
    [alertController addAction:cancel];

    [self presentViewController:alertController animated:YES completion:nil];
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
    return self.sharedDAO.companyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    

    // Each cell displays the company logo and company name
    CompanyClass *company = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:company.companyLogo];
    cell.detailTextLabel.text = company.companyStockQuote;
    cell.textLabel.text = company.companyName;
    
    // Long press gesture to edit company
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFrom:)] autorelease];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        CompanyClass* deleteCompany = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
        [self.sharedDAO deleteCompany:deleteCompany];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    CompanyClass *companyRow = [[self.sharedDAO.companyList objectAtIndex:fromIndexPath.row] retain];
    [self.sharedDAO.companyList removeObject:companyRow];
    [self.sharedDAO.companyList insertObject:companyRow atIndex:toIndexPath.row];
    [self.sharedDAO saveIndexChangestoCoreData];
    
//    companyRow.companyIndex = toIndexPath.row;
//    int count = 0;
//    for (NSInteger i = companyRow.companyIndex; i < self.sharedDAO.companyList.count; i++) {
//        
//        CompanyClass *company = [self.sharedDAO.companyList objectAtIndex:[companyRow.companyIndex + count]];
//        companyRow.companyIndex = toIndexPath.row + 1 + count;
//        count++;
//    }
    
    
  //  [companyRow release];
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

    self.productViewController.currentCompany = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
    
    // Sends you to products on next table?
    [self.navigationController
        pushViewController:self.productViewController
        animated:YES];
}
 

- (void)dealloc {
    [super dealloc];
}
@end
