//
//  Product.h
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSURL *productURL;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic) NSUInteger productID;
@property (nonatomic) NSUInteger productIndex;

- (id)initWithProductName:(NSString*)name andProductURL:(NSURL*)url andProductIndex:(NSUInteger)index andProductID:(NSUInteger)ID;
@end
