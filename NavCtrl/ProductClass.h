//
//  ProductClass.h
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductClass : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSURL *productURL;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic) NSUInteger productID;
@property (nonatomic) NSUInteger productIndex;

- (id)initWithProductName:(NSString*)name andProductURL:(NSURL*)url andProductIndex:(NSUInteger)index andProductID:(NSUInteger)ID;

@end
 