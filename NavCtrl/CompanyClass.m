//
//  CompanyClass.m
//  NavCtrl
//
//  Created by Julianne on 3/21/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CompanyClass.h"

@implementation CompanyClass

- (id)initWithCompanyName:(NSString*)name andCompanyLogo:(NSString*)logo andCompanyProducts:(NSMutableArray*)products andCompanyStockSymbol:(NSString *)symbol andCompanyIndex:(NSUInteger)index andCompanyID:(NSUInteger)ID {
   
    self = [super init];
    if (self) {
        
        _companyName = name;
        [_companyName retain];
        _companyLogo = logo;
        [_companyLogo retain];
        _companyProducts = products;
        [_companyProducts retain];
        _companyStockSymbol = symbol;
        [_companyStockSymbol retain];

        _companyIndex = index;
        _companyID = ID;
    }
    return(self);
}

- (void)dealloc {
    
    NSLog(@"dealloc company");
    
    [_companyProducts release];
    [_companyName release];
    [_companyLogo release];
    [_companyStockSymbol release];
    [super dealloc];
}

-(NSMutableArray*)companyProducts {
    
    if(!_companyProducts){
        _companyProducts = [[NSMutableArray alloc] init];
    }
    [_companyProducts retain];
    return _companyProducts;
}

@end
