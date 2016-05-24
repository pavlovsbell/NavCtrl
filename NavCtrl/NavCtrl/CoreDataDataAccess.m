//
//  CoreDataDataAccess.m
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CoreDataDataAccess.h"

@implementation CoreDataDataAccess

- (id)init {
    self = [super init];
    if (!self) return nil;
    [self initializeCoreData];
    return self;
}

- (void)initializeCoreData {
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    
    // Initialize Managed Object Model
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(managedObjectModel != nil, @"Error initializing Managed Object Model");
    // Initialize Persistent Store Coordinator
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    // Initialize Managed Object Context
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    self.managedObjectContext = managedObjectContext;
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    // Create UIManagedDocument
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[self managedObjectContext] persistentStoreCoordinator];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 NSSQLitePragmasOption, @{@"journal_mode":@"DELETE"},
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
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

- (void)postUndoDidFinish {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mocUndoDidFinish" object:nil];
    });
}

#pragma mark - Company Methods

- (NSArray*)fetchDataFromCoreData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return results;
}

- (Company*)createCompanyFromCompanyMO:(CompanyMO*)companyMO {
    Company *company = [[Company alloc] init];
    company.companyName = companyMO.companyName;
    company.companyLogo = companyMO.companyLogo;
    company.companyStockSymbol = companyMO.companyStockSymbol;
    company.companyID = [companyMO.companyID integerValue];
    company.companyIndex = [companyMO.companyIndex integerValue];
    NSArray *company_products = [companyMO.products allObjects];
    for (ProductMO *productMO in company_products) {
        Product *product = [self createProductFromProductMO:productMO];
        [company.companyProducts addObject:product];
    }
    return company;
}

- (void)createCompanyMOFromCompanyObject:(Company*)company {
    CompanyMO *companyMO = [NSEntityDescription insertNewObjectForEntityForName:@"CompanyMO" inManagedObjectContext:self.managedObjectContext];
    [self updateCompanyMOAttributes:companyMO withCompany:company];
    for (Product *product in company.companyProducts) {
        [self createProductMOFromProductObject:product forCompany:companyMO];
    }
    [self.managedObjectContext insertObject:companyMO];
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

- (void)deleteCompanyMOCorrespondingToCompany:(Company*)company {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"companyID == %d", company.companyID]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    CompanyMO *companyMO = [results objectAtIndex:0];    
    [self.managedObjectContext deleteObject:companyMO];
    for (ProductMO *productMO in companyMO.products){
        [self.managedObjectContext deleteObject:productMO];
    }
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

- (void)updateCompanyMOCorrespondingToCompany:(Company*)company {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CompanyMO"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"companyID == %d", company.companyID]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    [self updateCompanyMOAttributes:[results objectAtIndex:0] withCompany:company];
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

- (void)updateCompanyMOAttributes:(CompanyMO*)companyMO withCompany:(Company*)company {
    companyMO.companyName = company.companyName;
    companyMO.companyLogo = company.companyLogo;
    companyMO.companyStockSymbol = company.companyStockSymbol;
    companyMO.companyID = [NSNumber numberWithUnsignedInteger:company.companyID];
    companyMO.companyIndex = [NSNumber numberWithUnsignedInteger:company.companyIndex];
}

- (void)updateCompanyIndicesInCompanyList:(NSArray*)companyList {
    NSArray *CompanyMOs = [self fetchDataFromCoreData];
    for (Company *company in companyList) {
        for (CompanyMO *companyMO in CompanyMOs) {
            if ([companyMO.companyID isEqual:[NSNumber numberWithUnsignedInteger:company.companyID]]) {
                companyMO.companyIndex = [NSNumber numberWithUnsignedInteger:company.companyIndex];
            }
        }
    }
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

#pragma mark - Product methods

- (NSArray*)fetchProductDataFromCoreData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProductMO"];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return results;
}

- (Product*)createProductFromProductMO:(ProductMO*)productMO {
    Product *product = [[Product alloc] init];
    product.productName = productMO.productName;
    product.productURL = [NSURL URLWithString:productMO.productURL];
    product.productID = [productMO.productID integerValue];
    product.productIndex = [productMO.productIndex integerValue];
    return product;
}

- (void)createProductMOFromProductObject:(Product*)product forCompany:(CompanyMO*)companyMO {
    ProductMO *productMO = [[NSEntityDescription insertNewObjectForEntityForName:@"ProductMO" inManagedObjectContext:self.managedObjectContext] autorelease];
    productMO.productURL = [product.productURL absoluteString];
    productMO.productName = product.productName;
    productMO.productIndex = [NSNumber numberWithInteger:product.productIndex];
    productMO.productID = [NSNumber numberWithInteger:product.productID];
    productMO.soldBy = companyMO;
    [self.managedObjectContext insertObject:productMO];
}

- (void)updateProductMOCorrespondingToProduct:(Product*)product {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProductMO"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"productID == %d", product.productID]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    ProductMO *productMO = [results objectAtIndex:0];
    productMO.productName = product.productName;
    productMO.productURL = [product.productURL absoluteString];
    productMO.productID = [NSNumber numberWithUnsignedInteger:product.productID];
    productMO.productIndex = [NSNumber numberWithUnsignedInteger:product.productIndex];
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

- (void)deleteProductMOCorrespondingToProduct:(Product*)product {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProductMO"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"productID == %d", product.productID]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    ProductMO *productMO = [results objectAtIndex:0];
    [self.managedObjectContext deleteObject:productMO];
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

- (void)updateProductIndicesInProductArray:(NSArray*)productArray {
    NSArray *ProductMOs = [self fetchProductDataFromCoreData];
    for (Product *product in productArray) {
        for (ProductMO *productMO in ProductMOs) {
            if ([productMO.productID isEqual:[NSNumber numberWithUnsignedInteger:product.productID]]) {
                productMO.productIndex = [NSNumber numberWithUnsignedInteger:product.productIndex];
            }
        }
    }
    [self saveCoreData];
    [self.managedObjectContext.undoManager registerUndoWithTarget:self selector:@selector(postUndoDidFinish) object:nil];
}

@end
