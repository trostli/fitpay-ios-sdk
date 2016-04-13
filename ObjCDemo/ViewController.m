//
//  ViewController.m
//  ObjCDemo
//
//  Created by Igor Kravchenko on 4/8/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

#import "ViewController.h"
#import <FitpaySDK/FitpaySDK-Swift.h>

@interface ViewController ()

@property (nonatomic, strong) RestSession * session;
@property (nonatomic, strong) RestClient * rest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    _session = [[RestSession alloc] initWithClientId:@"pagare" redirectUri:@"http://demo.pagare.me"];
    ///_sess
       Transaction * transaction;
    NSString * transactionId = transaction.transactionId;
    
    
    
    
    
    _rest = [[RestClient alloc] initWithSession:_session];
   // NSLog(@"%@", _rest);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
