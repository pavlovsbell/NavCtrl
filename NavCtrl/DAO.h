//
//  DAO.h
//  NavCtrl
//
//  Created by Julianne on 3/22/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyClass.h"
#import "ProductClass.h"


@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray <CompanyClass*> *companyList;

+ (instancetype)sharedDAO;

@end
