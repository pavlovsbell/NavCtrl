//
//  Product.m
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "Product.h"

@implementation Product

- (id)initWithProductName:(NSString*)name andProductURL:(NSURL*)url andProductIndex:(NSUInteger)index andProductID:(NSUInteger)ID {
    
    self = [super init];
    if (self) {
        _productName = name;
        [_productName retain];
        _productURL = url;
        [_productURL = url retain];
        
        _urlString = _productURL.absoluteString;
        _productIndex = index;
        _productID = ID;
    }
    return(self);
}

@end
