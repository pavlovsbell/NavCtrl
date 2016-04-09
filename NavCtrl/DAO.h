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
#import "sqlite3.h"

@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray *companyList;


@property (strong) NSManagedObjectContext *managedObjectContext; //CoreData


-(void)initializeCoreData; //CoreData



+ (instancetype)sharedDAO;
- (void)copyDatabase;
- (void)displayCompany;
- (void)displayProducts;
- (void)addCompanyToDatabase:(CompanyClass*)newCompany;
- (void)addProduct:(ProductClass*)product toDatabaseOfCompany:(CompanyClass*)newCompany;
-(void)deleteCompanyFromDatabase:(int)deleteCompany;

@end
