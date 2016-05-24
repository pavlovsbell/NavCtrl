//
//  ProductCollectionViewController.m
//  NavCtrl
//
//  Created by Julianne on 5/20/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "ProductCollectionViewController.h"
#import "CompanyCollectionViewCell.h"
#import <WebKit/WebKit.h>

@interface ProductCollectionViewController () <WKNavigationDelegate>

@end

@implementation ProductCollectionViewController {
    UIBarButtonItem *editButton;
}

static NSString * const reuseIdentifier = @"Cell";

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        _currentCompany = [[Company alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedDAO = [DAO sharedDAO];
    self.clearsSelectionOnViewWillAppear = NO;
    [self setNavigationBarButtons];
    [self setObservers];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    NSLog(@"company %@", self.currentCompany.companyName);
    [self.collectionView registerNib:[UINib nibWithNibName:@"CompanyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"collectionViewCell"];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)setNavigationBarButtons {
    UIBarButtonItem *addProductButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct)];
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoLastProductAction)];
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editToDelete)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: undoButton, editButton, addProductButton, nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionData) name:@"mocUndoDidFinish" object:nil];
}

- (void)reloadCollectionData {
    [self.sharedDAO displayCompanyList];
    [self.collectionView reloadData];
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
        [self.collectionView reloadData];
    }];
    [alertController addAction:addProductAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editProductByLongPress:(UIGestureRecognizer*)longPressRecognizer {
    // Create new alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit product" message:@"Edit product name and URL" preferredStyle:UIAlertControllerStyleAlert];
    // Alert text fields
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.collectionView]];
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
        [self.collectionView reloadData];
    }];
    [alertController addAction:saveProductDetails];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setLongPressToCell:(UICollectionViewCell*)cell {
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editProductByLongPress:)] autorelease];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [longPressRecognizer setMinimumPressDuration:2];
    [cell addGestureRecognizer:longPressRecognizer];
}

- (void)undoLastProductAction {
    [self.sharedDAO undoLastAction];
//    [self reloadCollectionData];
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
    Product *product = [self.currentCompany.companyProducts objectAtIndex:currentIndexPath.row];
    [self.sharedDAO deleteProduct:product fromCompany:self.currentCompany];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentCompany.companyProducts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CompanyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    // Configure the cell
    if (cell == nil) {
        cell = [[CompanyCollectionViewCell alloc] init];
    }
    
    Product *product = [self.currentCompany.companyProducts objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageNamed:self.currentCompany.companyLogo];
    cell.companyName.text = product.productName;
    cell.deleteButton.hidden = YES;
    cell.stockQuote.hidden = YES;
    [self setLongPressToCell:cell];
    [self setDeleteButtonForCell:cell];
    [self setTapToDeleteButton:cell.deleteButton];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = [[UIViewController alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:viewController.view.frame];
    [viewController.view addSubview:webView];
    
    Product *currentProduct = [self.currentCompany.companyProducts objectAtIndex:indexPath.row];
    
    [webView loadRequest:[NSURLRequest requestWithURL:currentProduct.productURL]];
    webView.navigationDelegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
    
}
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

- (void)dealloc {
    [_productCollectionView release];
    [super dealloc];
}
@end
