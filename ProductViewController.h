//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductClass.h"
#import "CompanyClass.h"

@class ProductWebViewController;

@interface ProductViewController : UITableViewController
@property (nonatomic, retain) NSMutableArray *products;
@property (nonatomic, retain) UIImage *logo;
@property (nonatomic, retain) CompanyClass *currentCompany;



@end
