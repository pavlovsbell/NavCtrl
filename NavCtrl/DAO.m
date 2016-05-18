//
//  DAO.m
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//


#import "DAO.h"
#import "CompanyMO.h"
#import "ProductMO.h"

static DAO *myDAO = nil;


@interface DAO ()


@end


@implementation DAO

#pragma mark Singleton Methods
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
//- (unsigned)retainCount {
//    return UINT_MAX; //denotes an object that cannot be released
//}
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

        [self initializeCoreData];

        // Check to see if data is saved in Core Data
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        // If it's not there, the app should create the data using hard coded values and save it to Core Data
        if (!results || results.count == 0) {
            NSLog(@"Error fetching Company objects: %@\n%@", [error localizedDescription], [error userInfo]);
            [self loadDataIfNotExisting];
        }
        else {
            // Convert company managed objects to company classes
            [self createCompanyClassFrom:results];
        }
    }
    
    // Save companies to managed object context
    [self saveCoreData];
    
    return self;
}

#pragma mark - Core Data Methods
- (void)loadDataIfNotExisting {
    
    // Create all products - hard coded values
    ProductClass *appleIpad = [[[ProductClass alloc] initWithProductName:@"iPad" andProductURL:[NSURL URLWithString:@"http://www.apple.com/ipad/"] andProductIndex:0 andProductID:1] autorelease];
    
    ProductClass *appleIpod = [[[ProductClass alloc] initWithProductName:@"iPod" andProductURL:[NSURL URLWithString:@"http://www.apple.com/ipod/"] andProductIndex:1 andProductID:2] autorelease];
    
    ProductClass *appleIphone = [[[ProductClass alloc] initWithProductName:@"iPhone" andProductURL:[NSURL URLWithString:@"http://www.apple.com/iphone/"] andProductIndex:2 andProductID:3] autorelease];
    
    ProductClass *samsungS4 = [[[ProductClass alloc] initWithProductName:@"Galaxy S4" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/global/galaxy/"] andProductIndex:0 andProductID:4] autorelease];
    ProductClass *samsungNote = [[[ProductClass alloc] initWithProductName:@"Galaxy Note" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/global/galaxy/galaxy-note5/"] andProductIndex:1 andProductID:5] autorelease];
    ProductClass *samsungTab = [[[ProductClass alloc] initWithProductName:@"Galaxy Tab" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/us/mobile/galaxy-tab/"] andProductIndex:2 andProductID:6] autorelease];
    
    ProductClass *htcOne = [[[ProductClass alloc] initWithProductName:@"HTC One" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-one-m8/"] andProductIndex:0 andProductID:7] autorelease];
    ProductClass *htcNexus = [[[ProductClass alloc] initWithProductName:@"HTC Nexus" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/tablets/nexus-9/"] andProductIndex:1 andProductID:8] autorelease];
    ProductClass *htcDesire = [[[ProductClass alloc] initWithProductName:@"HTC Desire" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-desire-626/"] andProductIndex:2 andProductID:9] autorelease];
    
    ProductClass *blackberryClassic = [[[ProductClass alloc] initWithProductName:@"Blackberry Classic" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-classic/overview.html"] andProductIndex:0 andProductID:10] autorelease];
    ProductClass *blackberryPassport = [[[ProductClass alloc] initWithProductName:@"Blackberry Passport" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-passport/overview.html"] andProductIndex:1 andProductID:11] autorelease];
    ProductClass *blackberryPriv = [[[ProductClass alloc] initWithProductName:@"Blackberry Priv" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/priv-by-blackberry/overview.html"] andProductIndex:2 andProductID:12] autorelease];
    
    // Create product arrays
    NSMutableArray *appleProducts = [[NSMutableArray alloc] initWithObjects:appleIpad, appleIpod, appleIphone, nil];
    NSMutableArray *samsungProducts = [[NSMutableArray alloc] initWithObjects:samsungS4, samsungNote, samsungTab, nil];
    NSMutableArray *htcProducts = [[NSMutableArray alloc] initWithObjects:htcOne, htcNexus, htcDesire, nil];
    NSMutableArray *blackberryProducts = [[NSMutableArray alloc] initWithObjects:blackberryClassic, blackberryPassport, blackberryPriv, nil];
    
    // Create companies (each with name, logo and a product array)
    CompanyClass *apple = [[[CompanyClass alloc] initWithCompanyName:@"Apple mobile devices" andCompanyLogo:@"logoApple.png" andCompanyProducts:appleProducts andCompanyStockSymbol:@"AAPL" andCompanyIndex:0 andCompanyID:1] autorelease];
    CompanyClass *samsung = [[[CompanyClass alloc] initWithCompanyName:@"Samsung mobile devices" andCompanyLogo:@"logoSamsung.png" andCompanyProducts:samsungProducts andCompanyStockSymbol:@"005930.KS" andCompanyIndex:1 andCompanyID:2] autorelease];
    CompanyClass *htc = [[[CompanyClass alloc] initWithCompanyName:@"HTC mobile devices" andCompanyLogo:@"logoHTC.jpg" andCompanyProducts:htcProducts andCompanyStockSymbol:@"2498.TW" andCompanyIndex:2 andCompanyID:3] autorelease];
    CompanyClass *blackberry = [[[CompanyClass alloc] initWithCompanyName:@"Blackberry mobile devices" andCompanyLogo:@"logoBlackberry.png" andCompanyProducts:blackberryProducts andCompanyStockSymbol:@"BBRY" andCompanyIndex:3 andCompanyID:4] autorelease];
    
    // Put all companies in an array
    self.companyList = [[NSMutableArray alloc] initWithObjects:apple, samsung, htc, blackberry, nil];
    
    for (CompanyClass *companyFromList in self.companyList){
        [self createCompanyMOfrom:companyFromList];
    }
}
- (void)initializeCoreData {
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    
    // Initialize Managed Object Model
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    // Initialize Persistent Store Coordinator
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    // Initialize Managed Object Context
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    self.managedObjectContext = moc;
    
    // Create UIManagedDocument
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 NSSQLitePragmasOption, @{@"journal_mode":@"DELETE"},
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
    
    NSLog(@"%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
}
- (void)saveCoreData {
    if (self.managedObjectContext.hasChanges) {
        NSError *error = nil;
        if ([self.managedObjectContext save:&error] == NO) {
            NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}

#pragma mark - Create - Core Data Methods

- (void)createCompanyMOfrom:(CompanyClass*)companyClass {
    
    // Create temp company managed object
    CompanyMO *company = [[NSEntityDescription insertNewObjectForEntityForName:@"CompanyMO" inManagedObjectContext:self.managedObjectContext] autorelease];
    
    // Set attributes to company managed object
    company.companyLogo = companyClass.companyLogo;
    company.companyName = companyClass.companyName;
    company.companyIndex = [NSNumber numberWithInteger:companyClass.companyIndex];
    company.companyID = [NSNumber numberWithInteger:companyClass.companyID];
    
    if (!companyClass.companyStockSymbol){
        companyClass.companyStockSymbol = @"TTT";
    }
    company.companyStockSymbol = companyClass.companyStockSymbol;
    
    // Turn ProductClass products into product managed objects
    NSMutableArray *productsArray = [[[NSMutableArray alloc] init] autorelease];
    [self addProductsToCoreData:productsArray forCompany:company];
//    for (ProductClass *productInArray in companyClass.companyProducts) {
//        [self createProductMOFrom:productInArray ofCompany:company];
//        [productsArray addObject:productInArray];
//    }
    // Add company to managed object context
    [self.managedObjectContext insertObject:company];
}
- (void)createProductMOFrom:(ProductClass*)productClass ofCompany:(CompanyMO*)company {
    
    ProductMO *product = [[NSEntityDescription insertNewObjectForEntityForName:@"ProductMO" inManagedObjectContext:self.managedObjectContext] autorelease];
    product.productURL = [productClass.productURL absoluteString];
    product.productName = productClass.productName;
    product.productIndex = [NSNumber numberWithInteger:productClass.productIndex];
    product.soldBy = company;
    [self.managedObjectContext insertObject:product];
}

- (void)addCompanyToCoreData:(CompanyClass*)newCompany {
    [self createCompanyMOfrom:newCompany];
    [self saveCoreData];
}
- (void)addProductsToCoreData:(NSMutableArray*)productArray forCompany:(CompanyMO*)company {
    
    for (ProductClass *product in productArray) {
        [self createProductMOFrom:product ofCompany:company];
    }
    [self saveCoreData];
}


#pragma mark - Read - Core Data Methods

- (NSMutableArray*)sortCompanyListByIndex:(NSMutableArray*)companyList {
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"companyIndex" ascending:TRUE] autorelease];
    NSMutableArray *sortedArray = [[NSMutableArray new] autorelease];
    sortedArray = [[self.companyList sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];

    return sortedArray;
}

//- (void)createCompanyClassFrom:(CompanyMO*)companyMO {
//    
//    CompanyClass *companyClass = [[[CompanyClass alloc] init] autorelease];
//    companyClass.companyProducts = [[[NSMutableArray alloc]init] autorelease];
//
//}

- (void)createProductClassFrom:(NSArray*)productMOs forCompany:(CompanyClass*)company {
    
    for (ProductMO *productMO in productMOs) {
    
        NSString *product_name = productMO.productName;
        NSURL *product_url = [NSURL URLWithString:productMO.productURL];
        NSUInteger product_id = [productMO.productID integerValue];
        NSUInteger product_index = [productMO.productIndex integerValue];
        ProductClass *product = [[ProductClass alloc] initWithProductName:product_name andProductURL:product_url andProductIndex:product_index andProductID:product_id];
        
        [company.companyProducts addObject:product];
        [product release];
    }
}
- (void)createCompanyClassFrom:(NSArray*)companyMOs {

    self.companyList = [[[NSMutableArray alloc] init] autorelease];
    
    for (CompanyMO* companyMO in companyMOs) {
        NSString *company_name = companyMO.companyName;
        NSString *company_logo = companyMO.companyLogo;
        NSUInteger company_index = [companyMO.companyIndex intValue];
        NSUInteger company_id = [companyMO.companyID intValue];
        NSString *company_symbol = companyMO.companyStockSymbol;
        
        CompanyClass *company = [[CompanyClass alloc]initWithCompanyName:[company_name copy] andCompanyLogo:company_logo andCompanyProducts:nil andCompanyStockSymbol:company_symbol andCompanyIndex:company_index andCompanyID:company_id] ;
        
        
         if (companyMO.companyStockSymbol) {
            company.companyStockSymbol = companyMO.companyStockSymbol;
        }
        else {
            company.companyStockSymbol = @"000";
        }
        
        //company.companyProducts = [[[NSMutableArray alloc] init] autorelease];
        
        // Iterate through companyMO.products and turn each into a product object
        NSArray *company_products = [companyMO.products allObjects];
        
        [self createProductClassFrom:company_products forCompany:company];
        
        [self.companyList addObject:company];
        [company release];
    }
    self.companyList = [self sortCompanyListByIndex:self.companyList];
}

#pragma mark - Update - Core Data Methods

- (void)saveIndexChangestoCoreData {
 
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
//    
//    NSError *error = nil;
//    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
//    
////    for (int i = 0; i < results.count; i++) {
////        
////        CompanyMO *companyMO = [results objectAtIndex:i];
////        CompanyClass *companyClass = [self.companyList objectAtIndex:i];
////        companyMO.companyIndex = [NSNumber numberWithInteger:companyClass.companyIndex];
////    }
//
//
//        
//        for (CompanyClass *company in self.companyList){
//            company.companyIndex = [NSNumber numberWithLong:[self.companyList indexOfObject:company]];
//            for (CompanyMO *companyMO in results){
//                if ([company.companyID isEqualToNumber:[companyMO.companyID intValue]]){
//                    companyMO.companyIndex = [NSNumber numberWithInteger:company.companyIndex];
//                    break;
//                }
//            }
//        }
//     
//    [self saveCoreData];
}

- (void)saveCompanyChangesToCoreData:(CompanyClass*)company {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"companyID == %d", company.companyID]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    CompanyMO *companyMO = [results objectAtIndex:0];
    companyMO.companyName = company.companyName;
    
    [self saveCoreData];
}


#pragma mark - Delete - Core Data Methods

- (void)deleteCompany:(CompanyClass*)deleteCompany {
    
    [self.companyList removeObject:deleteCompany];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"companyID == %d", deleteCompany.companyID]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    CompanyMO* deleteMO = [results objectAtIndex:0];
    [self.managedObjectContext deleteObject:deleteMO];
    
    
    [self saveCoreData];
}

- (void)deleteProducts {
    //
}

@end