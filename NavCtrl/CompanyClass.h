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
@property (nonatomic, retain) UIImage *companyLogo;
@property (nonatomic, retain) NSString *companyStockPrice;
@property (nonatomic, retain) NSMutableArray <ProductClass*> *companyProducts;

- (id)initWithCompanyName:(NSString*)name andCompanyLogo:(UIImage*)logo andCompanyProducts:(NSMutableArray*)products;

@end
