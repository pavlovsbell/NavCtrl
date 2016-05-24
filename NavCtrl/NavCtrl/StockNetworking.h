//
//  StockNetworking.h
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CompanyViewController.h"
#import "CompanyCollectionViewController.h"
#import "AFNetworking.h"

@interface StockNetworking : NSObject

@property (strong, nonatomic) CompanyCollectionViewController *companyViewController;

- (void)getStockPrices;

@end