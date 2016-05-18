//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "ProductViewController.h"

@interface ProductViewController () <WKNavigationDelegate, WKScriptMessageHandler>
@end

@implementation ProductViewController

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
    [self setObservers];
}

- (void)setNavigationBarButtons {
    UIBarButtonItem *addProductButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct)];
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoLastProductAction)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: undoButton, self.editButtonItem, addProductButton, nil];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"mocUndoDidFinish" object:nil];
}

- (void)reloadTableData {
    [self.sharedDAO displayCompanyList];
    [self.tableView reloadData];
}

#pragma mark - Product Methods
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
        NSURL *url = [[[NSURL alloc] initWithString:alertController.textFields[1].text] autorelease];
        // Adding a new product; create new product with name and URL
        Product *newProduct = [[[Product alloc] initWithProductName:alertController.textFields[0].text andProductURL:url andProductIndex:self.currentCompany.companyProducts.count andProductID:self.currentCompany.companyProducts.count + 1] autorelease];
        
        [self.sharedDAO addProduct:newProduct toCompany:self.currentCompany];
        [self.tableView reloadData];
    }];
    [alertController addAction:addProductAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editProductByLongPress:(UIGestureRecognizer*)longPressRecognizer {
    // Create new alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit product" message:@"Edit product name and URL" preferredStyle:UIAlertControllerStyleAlert];
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
    Product *currentProduct = [self.currentCompany.companyProducts objectAtIndex:currentIndexPath.row];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancel){
    }];
    UIAlertAction *saveProductDetails = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *saveProductDetails){
        currentProduct.productName = alertController.textFields[0].text;
        // Turn URL string into URL
        NSURL *url = [[NSURL alloc] initWithString:alertController.textFields[1].text];
        currentProduct.productURL = url;
        [self.sharedDAO updateProduct:currentProduct ofCompany:self.currentCompany];
        [self.tableView reloadData];
    }];
    [alertController addAction:saveProductDetails];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setLongPressToCell:(UITableViewCell*)cell {
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editProductByLongPress:)] autorelease];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
}

- (void)undoLastProductAction {
    [self.sharedDAO undoLastAction];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.currentCompany.companyProducts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Each cell displays company logo and product name
    cell.textLabel.text = [[self.currentCompany.companyProducts objectAtIndex:[indexPath row]] productName];
    cell.imageView.image = [UIImage imageNamed:self.currentCompany.companyLogo];
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
        Product *product = [self.currentCompany.companyProducts objectAtIndex:indexPath.row];
        [self.sharedDAO deleteProduct:product fromCompany:self.currentCompany];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    Product *productRow = [[self.currentCompany.companyProducts objectAtIndex:fromIndexPath.row] retain];
    [self.currentCompany.companyProducts removeObject:productRow];
    [self.currentCompany.companyProducts insertObject:productRow atIndex:toIndexPath.row];
    [self.sharedDAO saveProductIndexChangesForProductArray:self.currentCompany.companyProducts];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = [[UIViewController alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:viewController.view.frame];
    [viewController.view addSubview:webView];
    
    Product *currentProduct = [self.currentCompany.companyProducts objectAtIndex:indexPath.row];
    
    [webView loadRequest:[NSURLRequest requestWithURL:currentProduct.productURL]];
    webView.navigationDelegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
}

@end
