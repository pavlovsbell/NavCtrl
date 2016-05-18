//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "Company.h"
#import "DAO.h"

@class ProductWebViewController;

@interface ProductViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *products;
@property (nonatomic, retain) UIImage *logo;
@property (nonatomic, retain) Company *currentCompany;
@property (nonatomic, retain) DAO *sharedDAO;

@end
