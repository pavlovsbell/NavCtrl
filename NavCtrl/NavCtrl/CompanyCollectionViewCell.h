//
//  CompanyCollectionViewCell.h
//  NavCtrl
//
//  Created by Julianne on 5/19/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyCollectionViewCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UILabel *companyName;
@property (retain, nonatomic) IBOutlet UILabel *stockQuote;
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)deleteButton:(id)sender;

@end
