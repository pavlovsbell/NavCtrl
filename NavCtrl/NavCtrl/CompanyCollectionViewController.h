//
//  CompanyCollectionViewController.h
//  NavCtrl
//
//  Created by Julianne on 5/19/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"

@class ProductCollectionViewController;

@interface CompanyCollectionViewController : UICollectionViewController

@property (nonatomic, retain) DAO *sharedDAO;
@property (retain, nonatomic) IBOutlet UICollectionView *companyCollectionView;
@property (nonatomic, retain) ProductCollectionViewController* productCollectionViewController;
@end
