//
//  CompanyCollectionViewController.m
//  NavCtrl
//
//  Created by Julianne on 5/19/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CompanyCollectionViewController.h"
#import "StockNetworking.h"
#import "Company.h"
#import "CompanyCollectionViewCell.h"
#import "ProductCollectionViewController.h"

@interface CompanyCollectionViewController ()

@end

@implementation CompanyCollectionViewController {
    UIBarButtonItem *editButton;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedDAO = [DAO sharedDAO];
    self.clearsSelectionOnViewWillAppear = NO;
    [self setNavigationBarButtons];
    self.title = @"Mobile device makers";
    [self.sharedDAO displayCompanyList];
    [self setObservers];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CompanyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"collectionViewCell"];
}

- (void)setNavigationBarButtons {
    UIBarButtonItem *addCompanyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCompany)];
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoLastCompanyAction)];
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editToDelete)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: undoButton,editButton, addCompanyButton, nil];
    self.navigationController.toolbarHidden = YES;
}

- (void)editToDelete {
    self.editing = !self.editing;
    if (self.editing == YES) {
        [editButton setTitle:@"Done"];
    }
    else {
        [editButton setTitle:@"Edit"];
    }
    [self.collectionView reloadData];
}

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCVData) name:@"mocUndoDidFinish" object:nil];
}

- (void)reloadCVData {
    [self.sharedDAO displayCompanyList];
    [self getStockPrices];
    [self.collectionView reloadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_companyCollectionView release];
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
        newCompany.companyStockQuote = @"N/A";
        newCompany.companyID = [self.sharedDAO calculateCompanyID];
        newCompany.companyIndex = self.sharedDAO.companyList.count;
        newCompany.companyProducts = nil;
        //[self.sharedDAO.companyList addObject:newCompany];
        [self.sharedDAO addCompany:newCompany];
        [self.collectionView reloadData];
    }] autorelease];
    [alertController addAction:addCompanyAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editCompanyByLongPress:(UIGestureRecognizer*)longPressRecognizer {
    NSLog(@"Pressed successfully");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit company" message:@"Edit company information" preferredStyle:UIAlertControllerStyleAlert];
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:[longPressRecognizer locationInView:self.collectionView]];
    
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
        [self.collectionView reloadData];
    }];
    
    [alertController addAction:saveCompanyDetails];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setLongPressToCell:(UICollectionViewCell*)cell {
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editCompanyByLongPress:)] autorelease];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
}

- (void)undoLastCompanyAction {
    [self.sharedDAO undoLastAction];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sharedDAO.companyList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CompanyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    // Configure the cell
    if (cell == nil ) {
        
        cell = [[CompanyCollectionViewCell alloc] init];
    }
    
    Company *company = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageNamed:company.companyLogo];
    cell.stockQuote.text = company.companyStockQuote;
    cell.companyName.text = company.companyName;
    cell.deleteButton.hidden = YES;
    [self setLongPressToCell:cell];
    [self setDeleteButtonForCell:cell];
    [self setTapToDeleteButton:cell.deleteButton];
//    [self setTapToCell:cell];
    return cell;
}

- (void)setDeleteButtonForCell:(CompanyCollectionViewCell*)cell {
    if (self.editing){
        cell.deleteButton.hidden = NO;
    } else {
        cell.deleteButton.hidden = YES;
    }
}

- (void)setTapToDeleteButton:(UIButton*)deleteButton {
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteItem:)] autorelease];
    [deleteButton addGestureRecognizer:tapGestureRecognizer];
}

- (void)deleteItem:(UIGestureRecognizer*)tapGestureRecognizer {
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:[tapGestureRecognizer locationInView:self.collectionView]];
    Company *company = [self.sharedDAO.companyList objectAtIndex:currentIndexPath.row];
    [self.sharedDAO deleteCompany:company];
    [self.collectionView reloadData];
}

- (void)setTapToCell:(CompanyCollectionViewCell*)cell {
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToProductsOfCompanyAtTap:)] autorelease];
    [cell addGestureRecognizer:tapGestureRecognizer];
}

- (void)goToProductsOfCompanyAtTap:(UIGestureRecognizer*)tapGestureRecognizer {
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:[tapGestureRecognizer locationInView:self.collectionView]];
    self.productCollectionViewController.currentCompany = [self.sharedDAO.companyList objectAtIndex:currentIndexPath.row];
    [self.navigationController pushViewController:self.productCollectionViewController animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCollectionViewController *collectionVC = [[ProductCollectionViewController alloc] initWithNibName:@"ProductCollectionViewController" bundle:nil];
    collectionVC.currentCompany = [self.sharedDAO.companyList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:collectionVC animated:YES];
    
}
#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}

@end
