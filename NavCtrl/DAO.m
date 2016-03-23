//
//  DAO.m
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "DAO.h"

static DAO *myDAO = nil;

@implementation DAO

#pragma mark Singleton Methods
+ (instancetype)sharedDAO {
    @synchronized(self) {
        if(myDAO == nil)
            myDAO = [[super allocWithZone:NULL] init];
        
    }
    return myDAO;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedDAO] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
//- (unsigned)retainCount {
//    return UINT_MAX; //denotes an object that cannot be released
//}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
- (id)init {
    if (self = [super init]) {
        // Create all products
        ProductClass *appleIpad = [[ProductClass alloc] initWithProductName:@"iPad" andProductURL:[NSURL URLWithString:@"http://www.apple.com/ipad/"]];
        ProductClass *appleIpod = [[ProductClass alloc] initWithProductName:@"iPod" andProductURL:[NSURL URLWithString:@"http://www.apple.com/ipod/"]];
        ProductClass *appleIphone = [[ProductClass alloc] initWithProductName:@"iPhone" andProductURL:[NSURL URLWithString:@"http://www.apple.com/iphone/"]];
        
        ProductClass *samsungS4 = [[ProductClass alloc] initWithProductName:@"Galaxy S4" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/global/galaxy/"]];
        ProductClass *samsungNote = [[ProductClass alloc] initWithProductName:@"Galaxy Note" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/global/galaxy/galaxy-note5/"]];
        ProductClass *samsungTab = [[ProductClass alloc] initWithProductName:@"Galaxy Tab" andProductURL:[NSURL URLWithString:@"http://www.samsung.com/us/mobile/galaxy-tab/"]];
        
        ProductClass *htcOne = [[ProductClass alloc] initWithProductName:@"HTC One" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-one-m8/"]];
        ProductClass *htcNexus = [[ProductClass alloc] initWithProductName:@"HTC Nexus" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/tablets/nexus-9/"]];
        ProductClass *htcDesire = [[ProductClass alloc] initWithProductName:@"HTC Desire" andProductURL:[NSURL URLWithString:@"http://www.htc.com/us/smartphones/htc-desire-626/"]];
        
        ProductClass *blackberryClassic = [[ProductClass alloc] initWithProductName:@"Blackberry Classic" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-classic/overview.html"]];
        ProductClass *blackberryPassport = [[ProductClass alloc] initWithProductName:@"Blackberry Passport" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/blackberry-passport/overview.html"]];
        ProductClass *blackberryPriv = [[ProductClass alloc] initWithProductName:@"Blackberry Priv" andProductURL:[NSURL URLWithString:@"http://us.blackberry.com/smartphones/priv-by-blackberry/overview.html"]];
        
        // Create product arrays
        NSMutableArray *appleProducts = [[NSMutableArray alloc] initWithObjects:appleIpad, appleIpod, appleIphone, nil];
        NSMutableArray *samsungProducts = [[NSMutableArray alloc] initWithObjects:samsungS4, samsungNote, samsungTab, nil];
        NSMutableArray *htcProducts = [[NSMutableArray alloc] initWithObjects:htcOne, htcNexus, htcDesire, nil];
        NSMutableArray *blackberryProducts = [[NSMutableArray alloc] initWithObjects:blackberryClassic, blackberryPassport, blackberryPriv, nil];
        
        // Create companies (each with name, logo and a product array)
        CompanyClass *apple = [[CompanyClass alloc] initWithCompanyName:@"Apple mobile devices" andCompanyLogo:[UIImage imageNamed:@"logoApple.png"] andCompanyProducts:appleProducts];
        CompanyClass *samsung = [[CompanyClass alloc] initWithCompanyName:@"Samsung mobile devices" andCompanyLogo:[UIImage imageNamed:@"logoSamsung.png"] andCompanyProducts:samsungProducts];
        CompanyClass *htc = [[CompanyClass alloc] initWithCompanyName:@"HTC mobile devices" andCompanyLogo:[UIImage imageNamed:@"logoHTC.jpg"] andCompanyProducts:htcProducts];
        CompanyClass *blackberry = [[CompanyClass alloc] initWithCompanyName:@"Blackberry mobile devices" andCompanyLogo:[UIImage imageNamed:@"logoBlackberry.png"] andCompanyProducts:blackberryProducts];
        
        // Put all companies in an array
        self.companyList = [[NSMutableArray alloc] initWithObjects:apple, samsung, htc, blackberry, nil];
    
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [super dealloc];
}

@end