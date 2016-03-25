//
//  CompanyClass.m
//  NavCtrl
//
//  Created by Julianne on 3/21/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CompanyClass.h"

@implementation CompanyClass

- (id)initWithCompanyName:(NSString*)name andCompanyLogo:(UIImage*)logo andCompanyProducts:(NSMutableArray*)products {
   
    self = [super init];
    if (self) {
        _companyLogo = [[UIImage alloc] init];
        _companyProducts = [[NSMutableArray alloc] init];
        _companyName = name;
        _companyLogo = logo;
        _companyProducts = products;
    }
    return(self);
}

@end
