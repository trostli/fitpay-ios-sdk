//
//  ViewController.m
//  ObjCDemo
//
//  Created by Igor Kravchenko on 4/8/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

#import "ViewController.h"
#import "ObjCDemo-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
      // NSLog(@"%@", _rest);
    Transaction * transaction; transaction.transactionTimeEpochObjC;
    
    User * user;
    Relationship * relationship;
    Commit * c;
    ApduPackage * apduPackage;
    DeviceInfo * deviceInfo;
    EncryptionKey * encryptionKey;
    VerificationMethod * verification;
    CreditCard * creditCard;
    ResultCollectionObjC * resultCollection;
    Asset * asset;
    RestSession * restSession;
    RestClient * restClient;
    
    NSString * ct = Commit.CommitType_CREDITCARD_CREATED;
    
    NSLog(@"AGogi:%@", [CreditCard TokenizationState_NEW]);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
