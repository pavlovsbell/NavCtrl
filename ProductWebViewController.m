//
//  ProductWebViewController.m
//  NavCtrl
//
//  Created by Julianne on 3/16/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "ProductWebViewController.h"

@interface ProductWebViewController ()

@end

@implementation ProductWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated {

    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:nsrequest];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_webView release];
    [super dealloc];
}
@end
