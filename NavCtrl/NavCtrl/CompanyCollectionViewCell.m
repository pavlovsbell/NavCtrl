//
//  CompanyCollectionViewCell.m
//  NavCtrl
//
//  Created by Julianne on 5/19/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CompanyCollectionViewCell.h"

@implementation CompanyCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc {
    [_image release];
    [_companyName release];
    [_stockQuote release];
    [_deleteButton release];
    [super dealloc];
}
- (IBAction)deleteButton:(id)sender {
    
    
}
@end
