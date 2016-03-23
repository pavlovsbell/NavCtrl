//
//  ProductClass.m
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "ProductClass.h"

@implementation ProductClass

- (id)initWithProductName:(NSString*)name andProductURL:(NSURL*)url {
    
    self = [super init];
    if (self) {
        self.productName = name;
        self.productURL = url;
    }
    return(self);
}

@end
