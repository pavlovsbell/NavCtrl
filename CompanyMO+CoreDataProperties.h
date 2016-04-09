//
//  CompanyMO+CoreDataProperties.h
//  NavCtrl
//
//  Created by Julianne on 4/8/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CompanyMO.h"
#import "ProductMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface CompanyMO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *companyIndex;
@property (nullable, nonatomic, retain) NSString *companyLogo;
@property (nullable, nonatomic, retain) NSString *companyName;
@property (nullable, nonatomic, retain) NSString *companyProducts;
@property (nullable, nonatomic, retain) NSString *companyStockPrice;
@property (nullable, nonatomic, retain) NSNumber *companyID;
@property (nullable, nonatomic, retain) NSSet<ProductMO *> *products;

@end

@interface CompanyMO (CoreDataGeneratedAccessors)

- (void)addProductsObject:(ProductMO *)value;
- (void)removeProductsObject:(ProductMO *)value;
- (void)addProducts:(NSSet<ProductMO *> *)values;
- (void)removeProducts:(NSSet<ProductMO *> *)values;

@end

NS_ASSUME_NONNULL_END
