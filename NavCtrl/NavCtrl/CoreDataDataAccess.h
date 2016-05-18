//
//  CoreDataDataAccess.h
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Company.h"
#import "Product.h"
#import "CompanyMO.h"
#import "ProductMO.h"

@interface CoreDataDataAccess : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)initializeCoreData;
- (NSArray*)fetchDataFromCoreData;
- (Company*)createCompanyFromCompanyMO:(CompanyMO*)companyMO;
- (void)createCompanyMOFromCompanyObject:(Company*)company;
- (void)createProductMOFromProductObject:(Product*)product forCompany:(CompanyMO*)companyMO;
- (void)deleteCompanyMOCorrespondingToCompany:(Company*)company;
- (void)deleteProductMOCorrespondingToProduct:(Product*)product;
- (void)updateCompanyMOCorrespondingToCompany:(Company*)company;
- (void)updateProductMOCorrespondingToProduct:(Product*)product;
- (void)updateCompanyIndicesInCompanyList:(NSArray*)companyList;
- (void)updateProductIndicesInProductArray:(NSArray*)productArray;
- (void)saveCoreData;
- (void)postUndoDidFinish;

@end
