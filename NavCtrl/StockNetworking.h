//
//  StockNetworking.h
//  NavCtrl
//
//  Created by Julianne on 4/14/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyViewController.h"


@interface StockNetworking : NSObject

@property (strong, nonatomic) CompanyViewController *companyViewController;

- (void)getStockPrices;

@end
