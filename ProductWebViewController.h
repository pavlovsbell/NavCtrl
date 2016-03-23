//
//  ProductWebViewController.h
//  NavCtrl
//
//  Created by Julianne on 3/16/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ProductWebViewController : UIViewController

@property (retain, nonatomic) IBOutlet WKWebView *webView;
@property (nonatomic, retain) NSURL *productURLRequest;

@end
