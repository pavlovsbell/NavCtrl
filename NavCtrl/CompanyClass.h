//
//  CompanyClass.h
//  NavCtrl
//
//  Created by Julianne on 3/21/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductClass.h"

@interface CompanyClass : NSObject

@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSString *companyLogo;
@property (nonatomic, retain) NSString *companyStockSymbol;
@property (nonatomic, retain) NSString *companyStockQuote;
@property (nonatomic, retain) NSMutableArray *companyProducts;
@property (nonatomic) NSUInteger companyID;
@property (nonatomic) NSUInteger companyIndex;

- (id)initWithCompanyName:(NSString*)name andCompanyLogo:(NSString*)logo andCompanyProducts:(NSMutableArray*)products andCompanyStockSymbol:(NSString*)symbol andCompanyIndex:(NSUInteger)index andCompanyID:(NSUInteger)ID;

@end
