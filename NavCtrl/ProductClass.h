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
@property (nonatomic) int productCompanyID;
@property (nonatomic) int productID;
@property (nonatomic) int productIndex;

- (id)initWithProductName:(NSString*)name andProductURL:(NSURL*)url;

@end
