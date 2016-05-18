//
//  CompanyViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "CompanyViewController.h"
#import "ProductViewController.h"
#import "StockNetworking.h"
#import "Company.h"

@interface CompanyViewController ()

@end

@implementation CompanyViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedDAO = [DAO sharedDAO];
    self.clearsSelectionOnViewWillAppear = NO;
    [self setNavigationBarButtons];
    self.title = @"Mobile device makers";
    [self.sharedDAO displayCompanyList];
    [self setObservers];
    
}

- (void)setNavigationBarButtons {
    UIBarButtonItem *addCompanyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCompany)];
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoLastCompanyAction)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: undoButton, self.editButtonItem, addCompanyButton, nil];
    self.navigationController.toolbarHidden = YES;
}

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"mocUndoDidFinish" object:nil];
}

- (void)reloadTableData {
    [self.sharedDAO displayCompanyList];
    [self getStockPrices];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    // Display stock quote for each company
    [super viewWillAppear:animated]; // Calls superclass, best practice
    [self getStockPrices];
}

- (void)getStockPrices {
    StockNetworking *networking = [[StockNetworking alloc] init];
    networking.companyViewController = self;
    [networking getStockPrices];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - My methods
- (void)addCompany {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a company" message:@"Please add your company name, stock symbol, and a number from 1-5 to generate a logo" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *companyNameText){
        companyNameText.placeholder = @"Company Name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *product1Text){
        product1Text.placeholder = @"Stock Symbol e.g. AAPL";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *product2Text){
        product2Text.placeholder = @"Choose a number from 1-5";
    }];
    UIAlertAction *cancel = [[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }] autorelease];
    UIAlertAction *addCompanyAction = [[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *addCompany){
        // Makes new company with name
        Company *newCompany = [[Company alloc] init];
        newCompany.companyName = alertController.textFields[0].text;
        newCompany.companyStockSymbol = alertController.textFields[1].text;
        newCompany.companyLogo = [self.sharedDAO retrieveCompanyLogoForNumber:alertController.textFields[2].text];
        newCompany.companyStockQuote = @"000";
        newCompany.companyID = [self.sharedDAO calculateCompanyID];
        newCompany.companyIndex = self.sharedDAO.companyList.count;
        newCompany.companyProducts = nil;
        //[self.sharedDAO.companyList addObject:newCompany];
        [self.sharedDAO addCompany:newCompany];
        [self.tableView reloadData];
    }] autorelease];
    [alertController addAction:addCompanyAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editCompanyByLongPress:(UIGestureRecognizer*)longPressRecognizer {
    NSLog(@"Pressed successfully");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit company" message:@"Edit company information" preferredStyle:UIAlertControllerStyleAlert];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
    
    Company *currentCompany = [self.sharedDAO.companyList objectAtIndex:[currentIndexPath row]];
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
        currentCompany.companyLogo = [self.sharedDAO retrieveCompanyLogoForNumber:alertController.textFields[2].text];
        [self.sharedDAO updateCompany:currentCompany];
        [self.tableView reloadData];
    }];
    
    [alertController addAction:saveCompanyDetails];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setLongPressToCell:(UITableViewCell*)cell {
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editCompanyByLongPress:)] autorelease];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
}

- (void)undoLastCompanyAction {
    [self.sharedDAO undoLastAction];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.sharedDAO.companyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Each cell displays the company logo and company name
    Company *company = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:company.companyLogo];
    cell.detailTextLabel.text = company.companyStockQuote;
    cell.textLabel.text = company.companyName;

    [self setLongPressToCell:cell];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Company* company = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
        [self.sharedDAO deleteCompany:company];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    Company *companyRow = [[self.sharedDAO.companyList objectAtIndex:fromIndexPath.row] retain];
    [self.sharedDAO.companyList removeObject:companyRow];
    [self.sharedDAO.companyList insertObject:companyRow atIndex:toIndexPath.row];
    [self.sharedDAO saveIndexChanges];
}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.productViewController.currentCompany = [self.sharedDAO.companyList objectAtIndex:indexPath.row];

    // Sends you to products on next table
    [self.navigationController
     pushViewController:self.productViewController
     animated:YES];
}

@end
