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

@interface CompanyViewController ()

- (void)addCompany;

@end

@implementation CompanyViewController

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
    
    self.title = @"Mobile device makers";
    
    // Add DAO to access all properties
    self.sharedDAO = [DAO sharedDAO];
    
    // Button to add a company
    UIBarButtonItem *addCompanyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCompany)];
    
    // Two buttons on the right side
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, addCompanyButton, nil];
    self.navigationController.toolbarHidden = YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    // Display stock quote for each company
    [super viewWillAppear:animated]; // Calls superclass, best practice
    [self getStockPrices];
    
}

- (void)getStockPrices {
    // Create NSURLSession
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    // Set URL to get data from
    NSURL *url = [NSURL URLWithString:@"http://finance.yahoo.com/d/quotes.csv?s=AAPL+005930.KS+2498.TW+BBRY&f=l1"];
    
    // Request to load the URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    // Retrieve the contents of the URL as a data object
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Turn data into a string
        NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"%@", content);
        
        // Create array to hold stock prices
        NSMutableArray *stockQuotes = [[[NSMutableArray alloc] initWithArray:[content componentsSeparatedByString:@"\n"]] autorelease];
//        stockQuotes = [content componentsSeparatedByString:@"\n"];
        
        // Add objects to array (for new companies)
        for (int c = 0; c < (self.sharedDAO.companyList.count); c++) {
            [stockQuotes addObject:@"0.00"];
        }
        
        // Loop through stockQuotes adding companyStockPrice for each
        for (int i = 0; i < self.sharedDAO.companyList.count; i++) {
//            [self.sharedDAO.companyList objectAtIndex:i].companyStockPrice = [stockQuotes objectAtIndex:i];
//            NSLog(@"Stock price for %@ is %@",[self.sharedDAO.companyList objectAtIndex:i].companyName,[self.sharedDAO.companyList objectAtIndex:i].companyStockPrice);
        }
        
        // Since we are in a block, must dispatch to get back to the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
              [self.tableView reloadData];
        });
    }];
    [dataTask resume];
    
}

- (void)addCompany {

    // Create new alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a company" message:@"Please add your company name and up to three products" preferredStyle:UIAlertControllerStyleAlert];
    
    // Alert text fields; get user input for properties
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
    
    // Alert buttons
    UIAlertAction *cancel = [[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }] autorelease];
    UIAlertAction *addCompanyAction = [[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *addCompany){
        
        
        // Adding a new company; create new company and create array for new company's products
        CompanyClass *newCompany = [[[CompanyClass alloc] init] autorelease];
        newCompany.companyProducts = [[[NSMutableArray alloc] init] autorelease];
        
        // Add new company name to company list
        if (alertController.textFields[0].text != nil){
            
            newCompany.companyName = alertController.textFields[0].text;
            
            // Add stock logo to new company and set stock price to 0
            newCompany.companyLogo = @"logoCompany.jpg";
            newCompany.companyStockPrice = @"0.00";
            newCompany.companyIndex = self.sharedDAO.companyList.count;
            
            [self.sharedDAO addCompanyToDatabase:newCompany];
            [self.tableView reloadData];
        }
       
        // Iterate through products and add them to new company's product array
       // NSString *string;
        
        for (int i = 1; i < alertController.textFields.count; i++) {
            if (alertController.textFields[i].text != nil) {
                ProductClass *product = [[ProductClass alloc] init];
                product.productName = alertController.textFields[i].text;
               // string = [NSString stringWithFormat:@"http://lmgtfy.com/?q=%@",product.productName];
                NSURL *url = [[NSURL alloc] initWithString:@"https://www.google.com/"];
                product.productURL = url;
                product.productIndex = newCompany.companyProducts.count;
//                product.productCompanyID = [self.sharedDAO.companyList objectAtIndex:self.sharedDAO.companyList.count - 1].companyID;
//                [newCompany.companyProducts addObject:product];
                [self.sharedDAO addProduct:product toDatabaseOfCompany:newCompany];
                [url release];
                [product release];
            }
        }
        [self.sharedDAO displayProducts];
    }] autorelease];
    
    [alertController addAction:addCompanyAction];
    [alertController addAction:cancel];
    
    // Make alert pop up when button pressed
    [self presentViewController:alertController animated:YES completion:nil];
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
    CompanyMO *company = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:company.companyLogo];
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companyStockPrice;
    
    // Long press gesture to edit company
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFrom:)] autorelease];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
    
    return cell;
}

- (void)handleLongPressFrom:(UIGestureRecognizer*)longPressRecognizer {
    NSLog(@"Pressed successfully");
    
    // Create new alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit company" message:@"Feel free to change the name" preferredStyle:UIAlertControllerStyleAlert];
    
    // Alert text fields
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *companyNameText){
        companyNameText.text = [[self.sharedDAO.companyList objectAtIndex:[currentIndexPath row]] companyName];
    }];
    
    // Alert buttons
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }];
    UIAlertAction *saveCompanyDetails = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *saveProductDetails){
//        [self.sharedDAO.companyList objectAtIndex:currentIndexPath.row].companyName = alertController.textFields[0].text;
        [self.tableView reloadData];
    }];
    
    [alertController addAction:saveCompanyDetails];
    [alertController addAction:cancel];
    
    // Make alert pop up when button pressed
    [self presentViewController:alertController animated:YES completion:nil];
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
        int companyId = [[self.sharedDAO.companyList objectAtIndex:indexPath.row]companyID];
        [self.sharedDAO deleteCompanyFromDatabase:companyId];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        
        [self.tableView reloadData];
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
//    [self.sharedDAO changedIndexSavedToDatabase];
    [companyRow release];
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
