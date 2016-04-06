//
//  DAO.m
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//


#import "DAO.h"

static DAO *myDAO = nil;


@interface DAO ()
{
    sqlite3 *database;
}

@property (strong, nonatomic) NSString *databasePathString;

@end


@implementation DAO

#pragma mark Singleton Methods
+ (instancetype)sharedDAO {
    @synchronized(self) {
        if(myDAO == nil)
            myDAO = [[[super allocWithZone:NULL] init] autorelease];
        
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
- (id)init {
    if (self = [super init]) {
    }
    return self;
}


#pragma mark Database Methods
- (void)copyDatabase {
    // Get path to current document/project and add database to it
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    self.databasePathString = [documentPath stringByAppendingPathComponent:@"NavCtrl.db"];
    NSFileManager *fileManager = [NSFileManager defaultManager]; // Create fileManager for manipulating files
    
    // Check to see if the database exists in the documents directory
    if (![fileManager fileExistsAtPath:self.databasePathString]) {
        // If database is not there, copy it from the bundle to the documents directory
        NSError *error = nil;
        NSString *bundleDBPath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"NavCtrl.db"];
        [fileManager copyItemAtPath:bundleDBPath toPath:self.databasePathString error:&error];
    }
    else
    {
        NSLog(@"Database exists");
    }
    
    // Initialize and allocate space for companyList; new = alloc,init
    self.companyList = [[NSMutableArray new] autorelease];
}

- (void)displayCompany {
    // All SQL must be converted into a prepared statement before it can be run
    sqlite3_stmt *statement;
    
    // Open database to access it; Check if successfully opened
    if (sqlite3_open([self.databasePathString UTF8String], &database) == SQLITE_OK) {
        [self.companyList removeAllObjects]; // Delete all data from company list
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Company"]; // Create query to select all company data to repopulate list
        const char *query_sql = [querySQL UTF8String]; // Convert an NSString to C string
        
        if (sqlite3_prepare_v2(database, query_sql, -1, &statement, NULL) == SQLITE_OK) // Run query through database
        {
            while (sqlite3_step(statement)== SQLITE_ROW) // While there are rows, SQL will be converted to a statement
            {
                // Have each database variable correspond to columns in the database
                NSString *companyId = [[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] autorelease];
                int company_id = companyId.intValue;
                NSString *companyInDex = [[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)] autorelease];
                int company_index = companyInDex.intValue;
                NSString *company_name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *company_logo = [[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)] autorelease];
                NSString *company_stockPrice = [[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)] autorelease];
                
                // Create new instance of company and set company properties to database variables
                CompanyClass *company = [[[CompanyClass alloc]initWithCompanyName:[company_name copy] andCompanyLogo:nil andCompanyProducts:nil]autorelease];
                company.companyLogo = company_logo;
                company.companyStockPrice = company_stockPrice;
                company.companyID = company_id;
                company.companyIndex = company_index;
                company.companyProducts = [[[NSMutableArray alloc] init] autorelease];
                
                [company_name release];
                
                [self.companyList addObject:company]; // Repopulate list with companies
            }
            
            // Finalize request
            if (sqlite3_finalize(statement) == SQLITE_OK){
                NSLog(@"Database closed");
            } else {
                NSAssert(false, @"Error finalized db: %s", sqlite3_errmsg(database));
                
            }
        }
        else {
            NSAssert(false, @"Error getting Company Table: %s", sqlite3_errmsg(database));
        }
        
    // Close database
    if (sqlite3_close(database) == SQLITE_OK){
        NSLog(@"Database closed");
    } else {
        NSAssert(false, @"Error closing db: %s", sqlite3_errmsg(database));
    }
    }
}

- (void)displayProducts {
    // All SQL must be converted into a prepared statement before it can be run
    sqlite3_stmt *statement;
    
    if(sqlite3_open([self.databasePathString UTF8String], &database)== SQLITE_OK){
        
        // Add products to companyProducts arrays
        for (CompanyClass *company in _companyList) {
            
            // Create query to select product data
            NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Product WHERE company_id = %d", company.companyID];
            const char *query_sql = [querySQL UTF8String]; // Convert an NSString to C string
            
            if (sqlite3_prepare_v2(database, query_sql, -1, &statement, NULL) == SQLITE_OK) // Run query through database
            {
                while (sqlite3_step(statement) == SQLITE_ROW) // While there are rows, SQL will be converted to a statement
                {
                    // Have each variable correspond to columns in the database
                    int company_id = (int)sqlite3_column_text(statement, 0);
                    int product_id = (int)sqlite3_column_text(statement, 1);
                    int product_index = (int)sqlite3_column_text(statement, 2);
                    NSString *product_name = [[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)] autorelease];
                    NSString *product_url = [[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)] autorelease];
                    
                    // Create new instance of product and fill company product array from database
                    ProductClass *product = [[[ProductClass alloc] init] autorelease];
                    product.productName = product_name;
                    product.productURL = [NSURL URLWithString:product_url];
                    product.productCompanyID = company_id;
                    product.productID = product_id;
                    product.productIndex = product_index;
                    [company.companyProducts addObject:product]; // Repopulate each company array with products
                }
            } else {
                NSAssert(false, @"Error getting Products: %s", sqlite3_errmsg(database));
            }
            if (sqlite3_finalize(statement) == SQLITE_OK){
                NSLog(@"Database closed");
                statement = nil;
            } else {
                NSAssert(false, @"Error finalized db: %s", sqlite3_errmsg(database));
            }

        }
        
        if (sqlite3_close(database) == SQLITE_OK){
            NSLog(@"Database closed");
        } else {
            NSAssert(false, @"Error finalized db: %s", sqlite3_errmsg(database));
            
        }
    }
}

- (void)addCompanyToDatabase:(CompanyClass*)newCompany {
    
    // Add new company to companyList
    [self.companyList addObject:newCompany];
    
    // Modify database to make added company permanent
    char *error; // SQL error in char variable
    if(sqlite3_open([self.databasePathString UTF8String], &database) == SQLITE_OK) // Open database to access it
    {
        
        NSString *insertStmt = [NSString stringWithFormat:@"INSERT INTO Company (company_name, company_logo, company_index, company_stockPrice) VALUES ('%@','%@','%d','%@')",newCompany.companyName,newCompany.companyLogo,newCompany.companyIndex,newCompany.companyStockPrice]; // Query to add company to database
        const char *insert_stmt = [insertStmt UTF8String]; // NSString to C string conversion

        if (sqlite3_exec(database, insert_stmt, NULL, NULL, &error) == SQLITE_OK) // Execute query to add company to database
        {
            NSLog(@"Company added to DB");
            UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"Add Company Complete" message:@"Company added to database" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
            [alert show]; // Alert confirming company was added to database

        } else{
            NSLog(@"%s", error);
        }
            
        sqlite3_close(database);
        
        [self displayCompany];
    }
}


- (void)addProduct:(ProductClass*)product toDatabaseOfCompany:(CompanyClass*)newCompany {

    // Add new product to company products array
    [newCompany.companyProducts addObject:product];
    
    // Modify database to make added product permanent
    char* error;
    if(sqlite3_open([self.databasePathString UTF8String], &database) == SQLITE_OK) {
        
        NSString *insertStmt = [NSString stringWithFormat:@"INSERT INTO Product (product_name, product_url, company_id, product_index) VALUES ('%@','%@','%d','%d')", product.productName, [product.productURL absoluteString], product.productCompanyID, product.productIndex];
        const char *insert_stmt = [insertStmt UTF8String];
        
        if (sqlite3_exec(database, insert_stmt, NULL, NULL, &error) == SQLITE_OK)
        {
            NSLog(@"Product added to DB");
        } else {
            NSLog(@"%s", error);
        }
        
        sqlite3_close(database);
    }
    //NSLog(@"%s,%s", product.productName, newCompany.companyName);
    
}


-(void)deleteCompanyFromDatabase:(int)deleteCompany
{
    char *error; // Errors for sqlite are in char form

    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM Company WHERE id IS '%d'", deleteCompany];
    NSLog(@"delete company = %d",deleteCompany);
    
    if(sqlite3_open([self.databasePathString UTF8String], &database)== SQLITE_OK){
    
    // Delete product
    if (sqlite3_exec(database, [deleteQuery UTF8String], NULL, NULL, &error) == SQLITE_OK)
    {
        NSLog(@"Company Deleted");
        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"Delete" message:@"Company Deleted" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
        [alert show];
    } else {
        NSLog(@"Error %s",error);
    }
       sqlite3_close(database);
        
    }
    for (int i = 0; i < self.companyList.count; i++) {
        if ([self.companyList[i] companyID] == deleteCompany) {
            [self.companyList removeObjectAtIndex:i];
            break;
        }
    }
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [super dealloc];
}

@end