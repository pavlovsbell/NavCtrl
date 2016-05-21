//
//  DAO.m
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "DAO.h"

static DAO *myDAO = nil;

@implementation DAO


#pragma mark - Data Methods

- (void)checkCoreDataForData {
    NSArray *results = [self.CDDA fetchDataFromCoreData];
    NSError *error = nil;
    // If it's not there, the app should create the data using hard coded values and save it to Core Data
    if (!results || results.count == 0) {
        NSLog(@"Error fetching Company objects: %@\n%@", [error localizedDescription], [error userInfo]);
        [self loadDataIfNotExisting];
    }
}

- (void)displayCompanyList {
    [self populateCompanyListFromCoreData];
    [self sortByCompanyIndex];
}
- (void)populateCompanyListFromCoreData {
    NSArray *managedObjects = [self.CDDA fetchDataFromCoreData];
    self.companyList = [[[NSMutableArray alloc] init] autorelease];
    for (CompanyMO *companyMO in managedObjects) {
        Company *company = [self.CDDA createCompanyFromCompanyMO:companyMO];
        [self.companyList addObject:company];
    }
}

- (void)undoLastAction {
    [self.CDDA.managedObjectContext.undoManager undo];
}

#pragma mark - Company Methods
- (void)addCompany:(Company*)company {
    [self.companyList addObject:company];
    NSLog(@"CDDA: %@", self.CDDA);
    [self.CDDA createCompanyMOFromCompanyObject:company];

}

- (void)deleteCompany:(Company*)company {
    [self.companyList removeObject:company];
    [self updateCompanyIndices];
    [self.CDDA deleteCompanyMOCorrespondingToCompany:company];
    [self.CDDA updateCompanyIndicesInCompanyList:self.companyList];
 
}

- (NSUInteger)calculateCompanyID {
    NSUInteger highestID = 0;
    for (Company *company in self.companyList) {
        if (company.companyID > highestID) {
            highestID = company.companyID;
        }
    }
    return highestID + 1;
}

- (NSString*)retrieveCompanyLogoForNumber:(id)number {
    // Make sure input is a number
    NSString *testString = number;
    NSScanner *scanner = [NSScanner scannerWithString:testString];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    NSString *companyLogo;
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
        companyLogo = [NSString stringWithFormat:@"logoCompany%d.jpg",logoNumber];
    }
    else {
        companyLogo = @"logoCompany5.jpg";
    }
    return companyLogo;
}

- (void)updateCompany:(Company*)company {
    [self.companyList removeObject:company];
    [self.companyList addObject:company];
    [self sortByCompanyIndex];
    [self.CDDA updateCompanyMOCorrespondingToCompany:company];
}

- (void)saveIndexChanges {
    [self updateCompanyIndices];
    [self.CDDA updateCompanyIndicesInCompanyList:self.companyList];
}

- (void)updateCompanyIndices {
    for (int i = 0; i < self.companyList.count; i++){
        [self.companyList objectAtIndex:i].companyIndex = i;
    }
}

- (void)sortByCompanyIndex {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"companyIndex" ascending:TRUE];
    self.companyList = [[self.companyList sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
}

#pragma mark - Product Methods

- (void)addProduct:(Product*)product toCompany:(Company*)company {
    [company.companyProducts addObject:product];
    // Save new product to Core Data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"companyID == %d", company.companyID]];
    NSError *error = nil;
    NSArray *results = [self.CDDA.managedObjectContext executeFetchRequest:request error:&error];
    CompanyMO *companyMO = [results objectAtIndex:0];
    [self.CDDA createProductMOFromProductObject:product forCompany:companyMO];
    [self.CDDA saveCoreData];
}

- (void)updateProduct:(Product*)product ofCompany:(Company*)company {
    [company.companyProducts removeObject:product];
    [company.companyProducts addObject:product];
    [self sortByProductIndexForProductArray:company.companyProducts];
    [self.CDDA updateProductMOCorrespondingToProduct:product];
}

- (void)deleteProduct:(Product*)product fromCompany:(Company *)currentCompany {
    [currentCompany.companyProducts removeObject:product];
    [self updateProductIndicesForProductArray:currentCompany.companyProducts];
    [self.CDDA deleteProductMOCorrespondingToProduct:product];
    [self.CDDA updateProductIndicesInProductArray:currentCompany.companyProducts];
}

- (void)updateProductIndicesForProductArray:(NSArray*)productArray {
    for (int i = 0; i < productArray.count; i++){
        Product *product = [productArray objectAtIndex:i];
        product.productIndex = i;
    }
}

- (void)saveProductIndexChangesForProductArray:(NSArray*)productArray {
    [self updateProductIndicesForProductArray:productArray];
    [self.CDDA updateProductIndicesInProductArray:productArray];
}

- (NSArray*)sortByProductIndexForProductArray:(NSArray*)productArray {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"productIndex" ascending:TRUE];
    NSArray *array = [productArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    return array;
}

- (void)loadDataIfNotExisting {
    // Create all products - hard coded values
    Product *appleIpad = [[[Product alloc] initWithProductName:@"iPad" andProductURL:[NSURL URLWithString:@"http://www.apple.com/ipad/"] andProductIndex:0 andProductID:1] autorelease];
    Product *appleIpod = [[[Product alloc] initWithProductName:@"iPod" andProductURL:[NSURL URLWithString:@"http://www.apple.com/ipod/"] andProductIndex:1 andProductID:2] autorelease];
    Product *appleIphone = [[[Product alloc] initWithProductName:@"iPhone" andProductURL:[NSURL URLWithString:@"http://www.apple.com/iphone/"] andProductIndex:2 andProductID:3] autorelease];
    Product *samsungS4 = [[[Product alloc] initWithProductName:@"Galaxy S4" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/global/galaxy/"] andProductIndex:0 andProductID:4] autorelease];
    Product *samsungNote = [[[Product alloc] initWithProductName:@"Galaxy Note" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/global/galaxy/galaxy-note5/"] andProductIndex:1 andProductID:5] autorelease];
    Product *samsungTab = [[[Product alloc] initWithProductName:@"Galaxy Tab" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/us/mobile/galaxy-tab/"] andProductIndex:2 andProductID:6] autorelease];
    Product *htcOne = [[[Product alloc] initWithProductName:@"HTC One" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-one-m8/"] andProductIndex:0 andProductID:7] autorelease];
    Product *htcNexus = [[[Product alloc] initWithProductName:@"HTC Nexus" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/tablets/nexus-9/"] andProductIndex:1 andProductID:8] autorelease];
    Product *htcDesire = [[[Product alloc] initWithProductName:@"HTC Desire" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-desire-626/"] andProductIndex:2 andProductID:9] autorelease];
    Product *blackberryClassic = [[[Product alloc] initWithProductName:@"Blackberry Classic" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-classic/overview.html"] andProductIndex:0 andProductID:10] autorelease];
    Product *blackberryPassport = [[[Product alloc] initWithProductName:@"Blackberry Passport" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-passport/overview.html"] andProductIndex:1 andProductID:11] autorelease];
    Product *blackberryPriv = [[[Product alloc] initWithProductName:@"Blackberry Priv" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/priv-by-blackberry/overview.html"] andProductIndex:2 andProductID:12] autorelease];
    
    // Create product arrays
    NSMutableArray *appleProducts = [[NSMutableArray alloc] initWithObjects:appleIpad, appleIpod, appleIphone, nil];
    NSMutableArray *samsungProducts = [[NSMutableArray alloc] initWithObjects:samsungS4, samsungNote, samsungTab, nil];
    NSMutableArray *htcProducts = [[NSMutableArray alloc] initWithObjects:htcOne, htcNexus, htcDesire, nil];
    NSMutableArray *blackberryProducts = [[NSMutableArray alloc] initWithObjects:blackberryClassic, blackberryPassport, blackberryPriv, nil];
    
    // Create companies (each with name, logo and a product array)
    Company *apple = [[[Company alloc] initWithCompanyName:@"Apple mobile devices" andCompanyLogo:@"logoApple.jpg" andCompanyProducts:appleProducts andCompanyStockSymbol:@"AAPL" andCompanyIndex:0 andCompanyID:1] autorelease];
    Company *samsung = [[[Company alloc] initWithCompanyName:@"Samsung mobile devices" andCompanyLogo:@"logoSamsung.png" andCompanyProducts:samsungProducts andCompanyStockSymbol:@"005930.KS" andCompanyIndex:1 andCompanyID:2] autorelease];
    Company *htc = [[[Company alloc] initWithCompanyName:@"HTC mobile devices" andCompanyLogo:@"logoHTC.jpg" andCompanyProducts:htcProducts andCompanyStockSymbol:@"2498.TW" andCompanyIndex:2 andCompanyID:3] autorelease];
    Company *blackberry = [[[Company alloc] initWithCompanyName:@"Blackberry mobile devices" andCompanyLogo:@"logoBlackberry.png" andCompanyProducts:blackberryProducts andCompanyStockSymbol:@"BBRY" andCompanyIndex:3 andCompanyID:4] autorelease];
    
    // Put all companies in an array
    self.companyList = [[NSMutableArray alloc] initWithObjects:apple, samsung, htc, blackberry, nil];
    
    for (Company *companyFromList in self.companyList){
        [self.CDDA createCompanyMOFromCompanyObject:companyFromList];
    }
}

#pragma mark - Singleton Methods
+ (instancetype)sharedDAO {
    @synchronized(self) {
        if(myDAO == nil)
            myDAO = [[super allocWithZone:NULL] init];
    }
    return myDAO;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedDAO] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned long)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [super dealloc];
}
- (id)init {
    if (self = [super init]) {
//        _CDDA = [[[CoreDataDataAccess alloc] init] autorelease];

        _CDDA = [[CoreDataDataAccess alloc] init];
        [self checkCoreDataForData];
    }
    [self.CDDA saveCoreData];
    return self;
}

@end

