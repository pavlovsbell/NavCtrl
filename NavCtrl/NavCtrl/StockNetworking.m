//
//  StockNetworking.m
//  NavCtrl
//
//  Created by Julianne on 5/15/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "StockNetworking.h"
#import "DAO.h"

@implementation StockNetworking

- (void)getStockPrices {
    DAO *sharedDAO = [DAO sharedDAO];
    NSMutableString *companyStockSymbols = [[NSMutableString new] autorelease];
    for (int i = 0; i < sharedDAO.companyList.count; i++) {
        Company *company = [sharedDAO.companyList objectAtIndex:i];
        if ([company.companyStockSymbol  isEqual:@""]) {
            [companyStockSymbols appendString:@"unknown"];
        }
        else {
            [companyStockSymbols appendString:company.companyStockSymbol];
        }
        if (i != sharedDAO.companyList.count - 1){
            unichar ch = '+';
            [companyStockSymbols appendString:[NSString stringWithCharacters:&ch length:1]];
        }
    }
    NSLog(@"%@", companyStockSymbols);

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *urlString = [NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?s=%@&f=l1", companyStockSymbols];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *downloadTask = [manager.session dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"%@", content);
        NSMutableArray *stockQuotes = [[[NSMutableArray alloc] initWithArray:[content componentsSeparatedByString:@"\n"]] autorelease];
        
        for (int i = 0; i < sharedDAO.companyList.count; i++) {
            Company *company = [sharedDAO.companyList objectAtIndex:i];
            company.companyStockQuote = [stockQuotes objectAtIndex:i];
        }
        // Since we are in a block, must dispatch to get back to the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.companyViewController.collectionView reloadData];
        });
    }];
    [downloadTask resume];
    
}

@end