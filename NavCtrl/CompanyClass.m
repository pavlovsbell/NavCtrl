//
//  CompanyClass.m
//  NavCtrl
//
//  Created by Julianne on 3/21/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CompanyClass.h"

@implementation CompanyClass

- (id)initWithCompanyName:(NSString*)name andCompanyLogo:(NSString*)logo andCompanyProducts:(NSMutableArray*)products {
   
    self = [super init];
    if (self) {
        _companyProducts = [[NSMutableArray alloc] init];
        _companyName = name;
        _companyLogo = logo;
        _companyProducts = products;
    }
    return(self);
}

- (void)dealloc {
    [_companyProducts release];
    [_companyName release];
    [_companyLogo release];
//    _companyProducts = nil;
//    _companyName = nil;
//    _companyLogo = nil;
    [super dealloc];
}


@end
