//
//  ProductCollectionViewController.h
//  NavCtrl
//
//  Created by Julianne on 5/20/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "Company.h"
#import "DAO.h"

@class ProductWebViewController;

@interface ProductCollectionViewController : UICollectionViewController <UICollectionViewDataSource>

@property (nonatomic, retain) NSMutableArray *products;
@property (retain, nonatomic) IBOutlet UICollectionView *productCollectionView;
@property (nonatomic, retain) UIImage *logo;
@property (nonatomic, retain) Company *currentCompany;
@property (nonatomic, retain) DAO *sharedDAO;

@end
