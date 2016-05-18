//
//  DAO.h
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataDataAccess.h"
#import "CompanyMO.h"
#import "Company.h"
#import "Product.h"

@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray <Company*> *companyList;
@property (retain, nonatomic) CoreDataDataAccess *CDDA;

+ (instancetype)sharedDAO;
- (NSUInteger)calculateCompanyID;
- (void)displayCompanyList;
- (void)populateCompanyListFromCoreData;
- (NSString*)retrieveCompanyLogoForNumber:(id)number;
- (void)addCompany:(Company*)company;
- (void)updateCompany:(Company*)company;
- (void)deleteCompany:(Company*)company;
- (void)saveIndexChanges;
- (void)addProduct:(Product*)product toCompany:(Company*)company;
- (void)updateProduct:(Product*)product ofCompany:(Company*)company;
- (void)deleteProduct:(Product*)product fromCompany:(Company*)currentCompany;
- (void)saveProductIndexChangesForProductArray:(NSArray*)productArray;
- (NSArray*)sortByProductIndexForProductArray:(NSArray*)productArray;
- (void)undoLastAction;

@end

