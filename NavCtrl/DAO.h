//
//  DAO.h
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CompanyClass.h"
#import "ProductClass.h"
#import "CompanyMO.h"

@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray *companyList;
@property (strong) NSManagedObjectContext *managedObjectContext;


+ (instancetype)sharedDAO;
- (void)initializeCoreData;

// Create - take table data and store in Core Data
- (void)createCompanyMOfrom:(CompanyClass*)companyClass;
- (void)createProductMOFrom:(ProductClass*)productClass ofCompany:(CompanyMO*)company;
- (void)addCompanyToCoreData:(CompanyClass*)newCompany;
- (void)addProductsToCoreData:(NSMutableArray*)productArray forCompany:(CompanyMO*)company;

// Read - take Core Data info and prepare to display in table
- (void)createCompanyClassFrom:(NSArray*)companyMOs;
- (NSMutableArray*)sortCompanyListByIndex:(NSMutableArray*)companyList;
- (void)createProductClassFrom:(NSArray*)productMOs forCompany:(CompanyClass*)company;

// Update
- (void)saveCompanyChangesToCoreData:(CompanyClass*)company;
- (void)saveIndexChangestoCoreData;

// Delete
- (void)deleteCompany:(CompanyClass*)deleteCompany;




@end
